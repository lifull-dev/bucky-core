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
          raise 'Currently only supports chrome. Sorry.' unless @@config[:browser] == :chrome

          options = Selenium::WebDriver::Chrome::Options.new
          options.add_emulation(user_agent: @@config[:user_agent]) if @@config[:user_agent]
          options.add_argument('--headless') if @@config[:headless]
          @@config[:chromedriver_flags].each { |flag| options.add_argument(flag) }
          # When SP device, set mobile emulation
          options.add_emulation(device_name: @@config[:device_name_on_chrome][@@config[:sp_device_name]]) if device_type == 'sp'
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.open_timeout = @@config[:driver_open_timeout]
          client.read_timeout = @@config[:driver_read_timeout]
          driver = Selenium::WebDriver.for :remote, url: "http://#{@@config[:selenium_ip]}:#{@@config[:selenium_port]}/wd/hub", options: options, http_client: client

          driver.manage.window.resize_to(1280, 1000)
          driver.manage.timeouts.implicit_wait = @@config[:find_element_timeout]
          driver
        rescue StandardError => e
          Bucky::Core::Exception::BuckyException.handle(e)
        end
        module_function :create_webdriver
      end
    end
  end
end
