# frozen_string_literal: true

require 'selenium-webdriver'
require_relative '../../core/exception/bucky_exception'
require_relative '../../utils/config'

module Bucky
  module TestEquipment
    module SeleniumHandler
      module WebdriverHandler
        # Create and return webdriver object
        # @param  [String] device_type e.g.) sp, pc, tablet
        # @return [Selenium::WebDriver]
        def create_webdriver(device_type)
          @@config = Bucky::Utils::Config.instance
          driver_args = create_driver_args(device_type)
          # Correctly create an options object
          options = generate_desire_caps(device_type)
          driver = Selenium::WebDriver.for :remote, url: driver_args[:url], options: options, http_client: driver_args[:http_client]
          driver.manage.window.resize_to(1920, 1080)
          driver.manage.timeouts.implicit_wait = @@config[:find_element_timeout]
          driver
        rescue StandardError => e
          Bucky::Core::Exception::BuckyException.handle(e)
        end
        module_function :create_webdriver

        private

        # @param  [String] device_type e.g.) sp, pc, tablet
        # @return [Hash] driver_args
        def create_driver_args(_device_type)
          {
            url: format('http://%<ip>s:%<port>s/wd/hub', ip: @@config[:selenium_ip], port: @@config[:selenium_port]),
            http_client: create_http_client
          }
        end

        def create_http_client
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.open_timeout = @@config[:driver_open_timeout]
          client.read_timeout = @@config[:driver_read_timeout]
          client
        end

        # Generate the desired capabilities
        # @param  [String] device_type e.g.) sp, pc, tablet
        # @return [Selenium::WebDriver::Options]
        def generate_desire_caps(device_type)
          case @@config[:browser]
          when :chrome
            set_chrome_option(device_type)
          else
            raise 'Currently only supports chrome. Sorry.'
          end
        end

        def set_chrome_option(device_type)
          options = Selenium::WebDriver::Options.chrome
          if %w[sp tablet].include?(device_type)
            device_type = "#{device_type}_device_name".to_sym
            options.add_emulation(device_name: @@config[:device_name_on_chrome][@@config[device_type]])
          end
          options.add_argument("--user-agent=#{@@config[:user_agent]}") if @@config[:user_agent]
          options.add_argument('--headless') if @@config[:headless]
          @@config[:chromedriver_flags]&.each do |flag|
            options.add_argument(flag)
          end
          options
        end
      end
    end
  end
end
