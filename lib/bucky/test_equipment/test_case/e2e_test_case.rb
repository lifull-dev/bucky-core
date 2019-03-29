# frozen_string_literal: true

require 'selenium-webdriver'
require_relative './abst_test_case'
require_relative '../user_operation/user_operator'
require_relative '../pageobject/pages'
require_relative '../selenium_handler/webdriver_handler'
require_relative '../verifications/js_error_checker'
require_relative '../verifications/service_verifications'

module Bucky
  module TestEquipment
    module TestCase
      class E2eTestCase < Bucky::TestEquipment::TestCase::AbstTestCase
        include Bucky::TestEquipment::SeleniumHandler::WebdriverHandler
        include Bucky::TestEquipment::Verifications::JsErrorChecker

        TEST_CATEGORY = 'e2e'

        class << self
          def startup; end

          def shutdown; end
        end

        # Initialize the following class
        #   - webdriver
        #   - page object
        #   - user oparation
        #   - verification
        # @param [Hash] suite
        def t_equip_setup
          @driver = create_webdriver(suite_data[:device])
          @pages = Bucky::TestEquipment::PageObject::Pages.new(suite_data[:service], suite_data[:device], @driver)
          service_verifications_args = { service: suite_data[:service], device: suite_data[:device], driver: @driver, pages: @pages, method_name: method_name }
          @service_verifications = Bucky::TestEquipment::Verifications::ServiceVerifications.new(service_verifications_args)
          user_operator_args = { app: suite_data[:service], device: suite_data[:device], driver: @driver, pages: @pages }
          @user_operator = Bucky::TestEquipment::UserOperation::UserOperator.new(user_operator_args)
        end

        # Call mothod of verification
        # @param [Hash] verify_args e.g.) {verify: "assert_title", expect: "page title"}
        def verify(**verify_args)
          @service_verifications.send(verify_args[:verify], verify_args)
        end

        # Call method of user operation
        # @param [Hash] op_args e.g.){page: 'top', part: 'rosen_tokyo', operation: 'click'}
        def operate(**op_args)
          @user_operator.send(op_args[:operate], method_name, op_args)
        end

        # Check javascript error
        def check_js_error
          assert_no_js_error(@driver) if @@config[:js_error_check]
        end

        def setup
          super
          t_equip_setup
        end

        def teardown
          @driver.quit
          super
        end
      end
    end
  end
end
