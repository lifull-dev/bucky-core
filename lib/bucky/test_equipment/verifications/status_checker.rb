# frozen_string_literal: true

require 'test/unit'
require 'nokogiri'
require 'parallel'
require_relative '../../utils/requests'
require_relative '../../utils/config'

REDIRECT_LIMIT = 5

# Check http status code from response
#   2xx -> OK
#   3xx -> request again
#   4xx~5xx -> NG

module Bucky
  module TestEquipment
    module Verifications
      module StatusChecker
        include Test::Unit::Assertions
        include Bucky::Utils::Requests

        # Check http status code
        # @param [String] url
        # @return [String] message
        def http_status_check(args)
          url = args[:url]
          device = args[:device]
          link_check_max_times = args[:link_check_max_times]
          url_log = args[:url_log]
          redirect_count = args[:redirect_count]
          redirect_url_list = args[:redirect_url_list]

          # If number of requests is over redirect limit
          return { error_message: "\n[Redirect Error] #{url} is redirected more than #{REDIRECT_LIMIT}" } if redirect_count > REDIRECT_LIMIT

          check_result = check_log_and_get_response(url, device, link_check_max_times, url_log)
          # If result include response continue to check, else return result
          !check_result.key?(:response) ? (return check_result) : response = check_result[:response]

          # Store original url
          redirect_url_list << url
          case response.code
          when /2[0-9]{2}/
            url_log[url][:entity] = response.entity
            puts "  #{url} ...  [#{response.code}:OK]"
            { entity: response.entity }
          when /3[0-9]{2}/
            fqdn = url[%r{^(https?:\/\/([a-zA-Z0-9\-_.]+))}]
            redirect_url = response['location']
            # Add fqdn if location doesn't include fqdn
            redirect_url = fqdn << redirect_url unless redirect_url.include?('http')
            puts "  #{url} ... redirect to #{redirect_url} [#{response.code}:RD]"
            http_status_check_args = { url: redirect_url, device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: redirect_count + 1, redirect_url_list: redirect_url_list }
            http_status_check(http_status_check_args)
          when /(4|5)[0-9]{2}/
            url_log[url][:error_message] = "[Status Error] http status returned #{response.code}.\ncheck this url: #{redirect_url_list.join(' -> ')}"
            puts "  #{url} ...  [#{response.code}:NG]"
            { error_message: url_log[url][:error_message] }
          else
            url_log[url][:error_message] = "[Status Code Invalid Error] Status Code is Invalid. \n Status:#{response.code}"
            { error_message: url_log[url][:error_message] }
          end
        end

        def link_status_check(args)
          url = args[:url]
          device = args[:device]
          exclude_urls = args[:exclude_urls]
          link_check_max_times = args[:link_check_max_times]
          url_log = args[:url_log]
          only_same_fqdn = args[:only_same_fqdn] ||= true

          # Extract base url and check if it is valid
          url_reg = %r{^(https?://([a-zA-Z0-9\-_.]+))}
          url_obj = url.match(url_reg)
          raise "Invalid URL #{url}" unless url_obj

          base_url  = url_obj[1]
          base_fqdn = url_obj[2]

          # Check base url
          http_status_check_args = { url: url, device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] }
          base_response = http_status_check(http_status_check_args)
          assert_nil(base_response[:error_message], "Response of base URL is incorrect.\n#{base_response[:error_message]}")

          # Collect links
          links_args = { base_url: base_url, base_fqdn: base_fqdn, url_reg: url_reg, only_same_fqdn: only_same_fqdn, entity: base_response[:entity] }
          links = make_target_links(links_args)
          links = exclude(links, exclude_urls) unless exclude_urls.nil?

          errors = []
          Parallel.each(links.uniq, in_threads: Bucky::Utils::Config.instance[:linkstatus_thread_num]) do |link|
            http_status_check_args[:url] = link
            http_status_check_args[:redirect_url_list] = []
            link_response = http_status_check(http_status_check_args)
            errors << link_response[:error_message] if link_response[:error_message]
          end
          assert_empty(errors, errors.join("\n"))
        end

        def make_target_links(args)
          base_url = args[:base_url]
          base_fqdn = args[:base_fqdn]
          url_reg = args[:url_reg]
          # TODO: Add an option that can handle the check if href's fqdn is not same with base fqdn
          # only_same_fqdn = args[:only_same_fqdn]
          entity = args[:entity]
          doc = Nokogiri::HTML.parse(entity)
          links = []
          doc.xpath('//a').each do |node|
            href = node.attr('href')&.split(' ')&.first # Patch for nokogiri's bug
            next if exclude_href?(href)

            # Add fqdn if href doesn't include fqdn
            unless url_reg.match?(href)
              links << format_href(base_url, href)
              next
            end

            href_fqdn = href.match(url_reg)[2]
            # TODO: Enable after only_same_fqdn can be handle
            # links << href if only_same_fqdn == false || base_fqdn == href_fqdn
            links << href if base_fqdn == href_fqdn
          end
          links
        end

        # Exclude non test target url
        def exclude(links, exclude_urls)
          excluded_links = links - exclude_urls

          # Exclude url if it has "*" in the last of it
          exclude_urls.each do |ex_url|
            next unless ex_url.end_with?('*')

            excluded_links.delete_if { |l| l.start_with?(ex_url.delete('*')) }
          end

          excluded_links
        end

        private

        def exclude_href?(href)
          return true if href.nil?

          exclude_regexps = [/^javascript.+/i, /^tel:\d.+/i, /^mailto:.+/i]
          exclude_regexps.keep_if { |reg| reg.match?(href) }
          return true unless exclude_regexps.empty?

          false
        end

        # Check result hash and submit request or return result.
        # Return: 1.(if request submitted) respons 2. (code 2xx)entity 3. (reach max check times)error message
        def check_log_and_get_response(url, device, link_check_max_times, url_log)
          unless url_log.key?(url)
            response = get_response(url, device, Bucky::Utils::Config.instance[:linkstatus_open_timeout], Bucky::Utils::Config.instance[:linkstatus_read_timeout])
            url_log[url] = { code: response.code, entity: nil, error_message: nil, count: 1 }
            return { response: response }
          end

          if url_log[url][:code].match?(/2[0-9]{2}/)
            puts "  #{url} is already [#{url_log[url][:code]}:OK]"
            return { entity: url_log[url][:entity] }
          elsif url_log[url][:count] >= link_check_max_times
            puts "  #{url} reach maximum check times [#{url_log[url][:code]}:NG]"
            return { error_message: url_log[url][:error_message] }
          else
            response = get_response(url, device, Bucky::Utils::Config.instance[:linkstatus_open_timeout], Bucky::Utils::Config.instance[:linkstatus_read_timeout])
            url_log[url][:count] += 1
            return { response: response }
          end
        end

        def format_href(base_url, href)
          href.insert(0, '/') unless href.match(%r{^/|^#})
          base_url + href
        end
      end
    end
  end
end
