# frozen_string_literal: true

require 'selenium-webdriver'
require 'English'

module Bucky
  module TestEquipment
    module SeleniumHandler
      module WaitHandler
        def wait_until_helper(timeout, interval, ignore, &block)
          wait = Selenium::WebDriver::Wait.new(timeout: timeout, interval: interval, ignore: [ignore])
          wait.until { block.call }
        rescue Selenium::WebDriver::Error::TimeoutError
          raise ignore, "Wait until the limit times for #{caller[1][/`([^']*)'/, 1]}\n   #{$ERROR_INFO.message}"
        end
        module_function :wait_until_helper
      end
    end
  end
end
