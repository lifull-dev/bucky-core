# frozen_string_literal: true

require_relative './db_connector'
require_relative '../../utils/config'

module Bucky
  module Core
    module Database
      class TestDataOperator
        def initialize
          @connector = DbConnector.new
          @connector.connect
          @config = Bucky::Utils::Config.instance
        end

        # Save job data and return job id
        # @param  [Time] start_time
        # @return [Fixnum] job_id
        def save_job_record_and_get_job_id(start_time, command_and_option)
          return 0 if $debug

          job_id = @connector.con[:jobs].insert(start_time: start_time, command_and_option: command_and_option)
          @connector.disconnect
          job_id
        end

        # Save test result
        # @param  [Hash] test_suite_result test data for Sequel
        def save_test_result(test_suite_result)
          @connector.con[:test_case_results].import(test_suite_result[:column], test_suite_result[:data_set])
          @connector.disconnect
        end

        # Add test_suites.id to loaded suite data
        # @return [Array] test_suite_data
        def add_suite_id_to_loaded_suite_data(test_suite_data)
          return test_suite_data if $debug

          test_suite_data.each_with_index do |test_data, i|
            suite = get_test_suite_from_test_data(test_data)
            test_suite_data[i][:test_suite_id] = suite[:id]
          end
          @connector.disconnect
          test_suite_data
        end

        # Save test suite data
        def update_test_suites_data(test_suite_data)
          return if $debug

          test_suite_data.each do |test_data|
            saved_test_suite = get_test_suite_from_test_data(test_data)
            suite_id = get_suite_id_from_saved_test_suite(saved_test_suite, test_data)
            test_data[:suite][:cases].each do |test_case|
              labels = get_labels_from_suite_and_case(test_data[:suite][:labels], test_case[:labels])
              label_ids = insert_and_return_label_ids(labels)
              update_test_case_and_test_case_label(suite_id, test_case, label_ids)
            end
          end
          @connector.disconnect
        end

        # Return file path and CaseName that failed at last time.
        # @return [Hash] re_test_cond
        def get_ng_test_cases_at_last_execution(cond)
          re_test_cond = {}
          return {} if $debug

          cases = @connector.con[:test_case_results].filter(cond).select(:test_case_id).all.map { |row| row[:test_case_id] }
          Sequel.split_symbols = true # To use test_cases__id
          suites_and_cases = @connector.con[:test_cases]
                                       .left_join(:test_suites, id: Sequel.qualify('test_cases', 'test_suite_id'))
                                       .where(test_cases__id: cases).all
          # Created data
          # {
          #   1 => {file_path: "/hoge/fuga.yml", cases_names: ["hogehoge_hoge_1", "hogehoge_hoge_2"]},
          #   2 => {file_path: "/gefu/hugo.yml", cases_names: ["hogehoge_hoge_1", "hogehoge_hoge_2"]},
          # }
          suites_and_cases.each do |suite_case|
            suite_id = suite_case[:test_suite_id]
            if re_test_cond.key? suite_id
              re_test_cond[suite_id][:case_names].push suite_case[:case_name]
            else
              re_test_cond[suite_id] = {
                file_path: suite_case[:file_path],
                case_names: [suite_case[:case_name]]
              }
            end
          end
          re_test_cond
        end

        def get_test_case_id(test_suite_id, case_name)
          return nil if $debug

          test_case = @connector.con[:test_cases].filter(test_suite_id: test_suite_id, case_name: case_name).first
          @connector.disconnect
          raise "Cannot get test_case id. test_suite_id: #{test_suite_id}, case_name: #{case_name}" if test_case.nil?

          test_case[:id]
        end

        # Return last round
        # @param  [Int] job_id
        # @return [Int] round
        def get_last_round_from_job_id(job_id)
          round = @connector.con[:test_case_results].where(job_id: job_id).max(:round)
          @connector.disconnect
          round
        end

        private

        # Common method for getting suite
        def get_test_suite_from_test_data(test_data)
          @connector.con[:test_suites].filter(
            test_category: test_data[:test_category],
            service: test_data[:suite][:service],
            device: test_data[:suite][:device],
            test_suite_name: test_data[:test_suite_name]
          ).first
        end

        def get_suite_id_from_saved_test_suite(saved_test_suite, test_data)
          file_path = "services/#{test_data[:suite][:service]}/#{test_data[:suite][:device]}/scenarios/#{test_data[:test_category]}/#{test_data[:test_suite_name]}.yml"
          if saved_test_suite
            @connector.con[:test_suites].where(id: saved_test_suite[:id]).update(
              priority: test_data[:suite][:priority].to_s,
              test_suite_name: test_data[:test_suite_name],
              suite_description: test_data[:suite][:desc],
              github_url: @config[:test_code_repo],
              file_path: file_path
            )
            saved_test_suite[:id]
          else # If there is no test_suite, save new record and return suite_id.
            @connector.con[:test_suites].insert(
              test_category: test_data[:test_category],
              service: test_data[:suite][:service],
              device: test_data[:suite][:device],
              priority: test_data[:suite][:priority].to_s,
              test_suite_name: test_data[:test_suite_name],
              suite_description: test_data[:suite][:desc],
              github_url: @config[:test_code_repo],
              file_path: file_path
            )
          end
        end

        # Return array contains suite and case
        def get_labels_from_suite_and_case(suite_labels, case_labels)
          [suite_labels, case_labels].flatten.compact.uniq
        end

        # Return label ids if case has labels, else return nil
        def insert_and_return_label_ids(labels)
          label_ids = []
          return nil if labels.empty?

          labels.each do |label_name|
            label = @connector.con[:labels].filter(label_name: label_name).first
            label_ids << if label
                           label[:id]
                         else
                           @connector.con[:labels].insert(label_name: label_name)
                         end
          end
          label_ids
        end

        def update_test_case_and_test_case_label(suite_id, test_case, label_ids)
          saved_test_case = @connector.con[:test_cases].filter(test_suite_id: suite_id, case_name: test_case[:case_name]).first
          if saved_test_case
            # Update case data
            @connector.con[:test_cases].where(id: saved_test_case[:id]).update(case_name: test_case[:case_name], case_description: test_case[:desc])
            # Update label of case
            # At first, delete case connection
            @connector.con[:test_case_labels].filter(test_case_id: saved_test_case[:id]).delete
            # Create new connection
            # If there is no labels, return nil
            label_ids&.each do |label_id|
              @connector.con[:test_case_labels].insert(test_case_id: saved_test_case[:id], label_id: label_id)
            end
          else
            # Add case data
            test_case_id = @connector.con[:test_cases].insert(test_suite_id: suite_id, case_name: test_case[:case_name], case_description: test_case[:desc])
            # If there is no labels, return nil
            label_ids&.each do |label_id|
              @connector.con[:test_case_labels].insert(test_case_id: test_case_id, label_id: label_id)
            end
          end
        end
      end
    end
  end
end
