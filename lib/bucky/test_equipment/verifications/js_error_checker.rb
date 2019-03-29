# frozen_string_literal: true

require 'test/unit'

module Bucky
  module TestEquipment
    module Verifications
      module JsErrorChecker
        include Test::Unit::Assertions

        # Check Javascript Error in page
        # @param [Webdriver] driver
        def assert_no_js_error(driver)
          js_errors = driver.execute_script(
            'return window.JSErrorCollector_errors ? window.JSErrorCollector_errors.pump() : []'
          )
          # Empty is ok
          assert_empty(js_errors, '[JS Error]')
        end
      end
    end
  end
end
