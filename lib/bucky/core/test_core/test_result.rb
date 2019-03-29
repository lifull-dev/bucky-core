# frozen_string_literal: true

require 'singleton'
require 'json'
require 'test/unit/testresult'

require_relative '../database/test_data_operator'

module Bucky
  module Core
    module TestCore
      class TestResult
        include Singleton

        attr_accessor :result

        def initialize
          @result = Test::Unit::TestResult.new
          @tdo = Bucky::Core::Database::TestDataOperator.new
        end

        # Save test result
        # @param [Array] added_result_info
        def save(added_result_info)
          # Format data before saving to database.
          test_suite_result = format_result_summary(added_result_info)
          @tdo.save_test_result(test_suite_result)
        end

        private

        # Return Bucky::Test::Unit::TestResult Object
        # @param [Array] added_result_info
        # @return [Array] Array data for Sequel
        def format_result_summary(added_result_info)
          # For sequel
          data_set = {}
          error_test_case_name = []

          ##############################################
          # Store failed cases in data set. #
          ##############################################
          @result.faults.each do |fault|
            case_name = fault.method_name
            case_id = @tdo.get_test_case_id(added_result_info[case_name.to_sym][:test_suite_id], added_result_info[case_name.to_sym][:case_name])
            error_test_case_name.push(case_name.to_sym)
            data_set[case_name] =
              [
                id = nil,
                test_case_id = case_id,
                error_title = fault.message,
                error_message = fault.location.join("\n"),
                elapsed_time = added_result_info[case_name.to_sym][:elapsed_time],
                is_error = 1,
                job_id = $job_id,
                round = $round
              ]
          end

          ############################################
          # Store passed cases in data set. #
          ############################################
          added_result_info.delete_if { |k, _v| error_test_case_name.include?(k) }
          added_result_info.each do |case_name, added_info|
            case_id = @tdo.get_test_case_id(added_info[:test_suite_id], added_info[:case_name])
            data_set[case_name] =
              [
                id = nil,
                test_case_id = case_id,
                error_title = '',
                error_message = '',
                elapsed_time = added_info[:elapsed_time],
                is_error = 0,
                job_id = $job_id,
                round = $round
              ]
          end

          # Data set for sequel
          data_set_ary = data_set.map { |_, v| v }

          # Table colomn
          column_name_ary = %i[id test_case_id error_title error_message elapsed_time is_error job_id round]
          {
            column: column_name_ary,
            data_set: data_set_ary
          }
        end
      end
    end
  end
end
