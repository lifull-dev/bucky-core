# frozen_string_literal: true

require 'net/http'
require 'addressable/uri'

module Bucky
  module Utils
    module Requests
      USER_AGENT_STRING = {
        pc: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36',
        sp: 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13E238 Safari/601.1'
      }.freeze

      # @param  [String]    uri
      # @param  [String]    device
      # @param  [Integer/Float] open_timeout max wait time until open page
      # @param  [Integer/Float] read_timeout max wait time until recieve response
      # @return [Net::HTTP]         HttpStatusCode
      def get_response(uri, device, open_timeout, read_timeout)
        parsed_uri = Addressable::URI.parse(uri.to_str.strip)
        query = parsed_uri.query ? "?#{CGI.escape(parsed_uri.query)}" : ''
        # If path is empty, add "/" e.g) http://example.com
        path = parsed_uri.path.empty? ? '/' : parsed_uri.path

        Net::HTTP.start(parsed_uri.host, parsed_uri.port, use_ssl: parsed_uri.scheme == 'https') do |http|
          http.open_timeout = open_timeout
          http.read_timeout = read_timeout
          http.get("#{path}#{query}", 'User-Agent' => USER_AGENT_STRING[device.to_sym])
        end
      end
    end
  end
end
