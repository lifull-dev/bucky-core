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
          driver = Selenium::WebDriver.for(:remote, **driver_args)
          driver.manage.window.resize_to(1280, 1000)
          driver.manage.timeouts.implicit_wait = @@config[:find_element_timeout]
          driver
        rescue StandardError => e
          Bucky::Core::Exception::BuckyException.handle(e)
        end
        module_function :create_webdriver

        private

        # @param  [String] device_type e.g.) sp, pc, tablet
        # @return [Hash] driver_args
        def create_driver_args(device_type)
          driver_args = { url: format('http://%<ip>s:%<port>s/wd/hub', ip: @@config[:selenium_ip], port: @@config[:selenium_port]) }
          driver_args[:desired_capabilities] = generate_desire_caps(device_type)
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.open_timeout = @@config[:driver_open_timeout]
          client.read_timeout = @@config[:driver_read_timeout]
          driver_args[:http_client] = client
          driver_args
        end

        # @param  [String] device_type e.g.) sp, pc, tablet
        # @return [Hash]   desire_capabilities
        def generate_desire_caps(device_type)
          case @@config[:browser]
          when :chrome then
            set_chrome_option(device_type)
          else
            raise 'Currently only supports chrome. Sorry.'
          end
        end

        def set_chrome_option(device_type)
          chrome_options = { 'chromeOptions' => { args: [] } }
          unless device_type == 'pc'
            device_type = "#{device_type}_device_name".to_sym
            mobile_emulation = { 'deviceName' => @@config[:device_name_on_chrome][@@config[device_type]] }
            chrome_options['chromeOptions']['mobileEmulation'] = mobile_emulation
          end
          chrome_options['chromeOptions'][:args] << "--load-extension=#{@@config[:js_error_collector_path]}" if @@config[:js_error_check]
          chrome_options['chromeOptions'][:args] << "--user-agent=#{@@config[:user_agent]}" if @@config[:user_agent]
          chrome_options['chromeOptions'][:args] << '--headless' if @@config[:headless]

          Selenium::WebDriver::Remote::Capabilities.chrome(chrome_options)
        end
      end
    end
  end
end
