# frozen_string_literal: true

require 'parallel'
require_relative '../test_core/test_case_loader'
require_relative '../../utils/config'
require_relative './test_class_generator'
require_relative '../test_core/exit_handler'

module Bucky
  module Core
    module TestCore
      module ParallelHelper
        parent_pid = Process.pid

        # Terminate parent and child process when getting interrupt signal
        Signal.trap('INT') do
          Process.kill('TERM', -1 * parent_pid)
        end

        private

        def parallel_new_worker_each(data_set, max_processes, &block)
          # Max parallel workers number
          available_workers = max_processes

          # If child process dead, available workers increase
          Signal.trap('CLD') { available_workers += 1 }

          data_set.each do |data|
            # Wait until worker is available
            Process.wait unless available_workers.positive?
            # Workers decrease when start working
            available_workers -= 1
            fork { block.call(data) }
          end
          Process.waitall
        end

        def parallel_distribute_into_workers(data_set, max_processes, &block)
          # Group the data by remainder of index
          data_set_grouped = data_set.group_by.with_index { |_elem, index| index % max_processes }
          # Use 'values' method to get only hash's key into an array
          data_set_grouped.values.each do |data_for_pre_worker|
            # Number of child process is equal to max_processes (or equal to data_set length when data_set length is less than max_processes)
            fork do
              data_for_pre_worker.each { |data| block.call(data) }
            end
          end
          Process.waitall
        end
      end

      class TestManager
        include ParallelHelper

        # Keep test conditions and round number
        def initialize(test_cond)
          @test_cond = test_cond
          @re_test_count = @test_cond[:re_test_count]
          @tdo = Bucky::Core::Database::TestDataOperator.new
          @start_time = Time.now
          $job_id = @tdo.save_job_record_and_get_job_id(@start_time, @test_cond[:command_and_option])
        end

        def run
          execute_test
        end

        # Rerun by job id
        def rerun
          rerun_job_id = @test_cond[:job]
          $round = @tdo.get_last_round_from_job_id(rerun_job_id)
          @test_cond[:re_test_cond] = @tdo.get_ng_test_cases_at_last_execution(
            is_error: 1, job_id: rerun_job_id, round: $round
          )
          execute_test
        end

        private

        # Load test suite from test code.
        def load_test_suites
          test_suite_data = Bucky::Core::TestCore::TestCaseLoader.load_testcode(@test_cond)
          raise StandardError, "\nThere is no test case!\nPlease check test condition." if test_suite_data.empty?

          @tdo.update_test_suites_data(test_suite_data)
          @tdo.add_suite_id_to_loaded_suite_data(test_suite_data)
        end

        # Generate and execute test
        def do_test_suites(test_suite_data)
          # For checking on linkstatus
          e2e_parallel_num = Bucky::Utils::Config.instance[:e2e_parallel_num]
          linkstatus_parallel_num = Bucky::Utils::Config.instance[:linkstatus_parallel_num]
          tcg = Bucky::Core::TestCore::TestClassGenerator.new(@test_cond)

          case @test_cond[:test_category][0]
          when 'e2e' then parallel_new_worker_each(test_suite_data, e2e_parallel_num) { |data| tcg.generate_test_class(data) }
          when 'linkstatus' then
            link_status_url_log = {}
            parallel_distribute_into_workers(test_suite_data, linkstatus_parallel_num) { |data| tcg.generate_test_class(data, link_status_url_log) }
          end
        end

        def execute_test
          @re_test_count.times do |i|
            Bucky::Core::TestCore::ExitHandler.reset
            $round = i + 1
            test_suite_data = load_test_suites
            do_test_suites(test_suite_data)
            @test_cond[:re_test_cond] = @tdo.get_ng_test_cases_at_last_execution(
              is_error: 1, job_id: $job_id, round: $round
            )
            break if @test_cond[:re_test_cond].empty?
          end
        end
      end
    end
  end
end
