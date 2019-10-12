# frozen_string_literal: true

require 'test/unit'
require_relative '../../core/test_core/test_result'

module Bucky
  module TestEquipment
    module TestCase
      class AbstTestCase < Test::Unit::TestCase
        class << self
          @@test_case_fail = false

          def startup
            return if $debug

            @@this_result = Bucky::Core::TestCore::TestResult.instance
            @@added_result_info = {}
          end

          def shutdown
            @@this_result.save(@@added_result_info) unless $debug
          end
        end

        # Override Test::Unit::TestCase#run
        # Save test result to own test result object.
        def run(result)
          super
          @@this_result.result = result unless $debug
        end

        def setup
          # To make it easy to read
          puts "\n"
        end

        def teardown
          @@test_case_fail = true unless passed?
          return if $debug

          @@added_result_info[method_name.to_sym] = {
            test_suite_id: suite_id,
            elapsed_time: Time.now - start_time,
            case_name: description
          }
        end

        def cleanup; end

        Test::Unit.at_exit do
          exit 1 if @@test_case_fail == true
        end
      end
    end
  end
end
