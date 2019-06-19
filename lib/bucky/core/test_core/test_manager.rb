# frozen_string_literal: true

require 'parallel'
require_relative '../test_core/test_case_loader'
require_relative '../../utils/config'
require_relative './test_class_generator'

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

        def parallel_new_worker_each(test_suite_data, max_processes)
          # Max parallel workers number
          available_workers = max_processes

          # If child process dead, available workers increase
          Signal.trap('CLD') { available_workers += 1 }

          test_suite_data.each do |_data|
            # Wait until worker is available
            Process.wait unless available_workers.positive?
            # Workers decrease when start working
            available_workers -= 1
            fork { @tcg.generate_test_class(data) }
          end
          Process.waitall
        end

        def parallel_distribute_into_workers(test_suite_data, max_processes)
          # For checking on linkstatus
          link_status_url_log = {}
          divisor_of_data = max_processes
          # The remainder will influence number of parts when slicing test_suite_data, -1 to keep result parts in expected number
          divisor_of_data -= 1 unless (test_suite_data.length % divisor_of_data).zero?
          # Use 1 if only one suite is in test_suite_data
          num_of_works_in_pre_worker = (test_suite_data.length == 1 ? 1 : (test_suite_data.length / divisor_of_data))

          # Slice test_suite_data into few parts that depends on workers
          test_suite_data.each_slice(num_of_works_in_pre_worker) do |test_suite_for_pre_worker|
            # Number of child process is equal to max_processes
            fork do
              test_suite_for_pre_worker.each { |data| @tcg.generate_test_class(data, link_status_url_log) }
            end
          end
          Process.waitall
        end
      end

      class TestManager
        # Keep test conditions and round number
        def initialize(test_cond)
          @test_cond = test_cond
          @re_test_count = @test_cond[:re_test_count]
          @tdo = Bucky::Core::Database::TestDataOperator.new
          @start_time = Time.now
          $job_id = @tdo.save_job_record_and_get_job_id(@start_time, @test_cond[:command_and_option])
          @tcg = Bucky::Core::TestCore::TestClassGenerator.new(test_cond)
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
          extend ParallelHelper
          e2e_parallel_num = Bucky::Utils::Config.instance[:e2e_parallel_num]
          linkstatus_parallel_num = Bucky::Utils::Config.instance[:linkstatus_parallel_num]

          case @test_cond[:test_category][0]
          when 'e2e' then parallel_new_worker_each(test_suite_data, e2e_parallel_num)
          when 'linkstatus' then parallel_distribute_into_workers(test_suite_data, linkstatus_parallel_num)
          end
        end

        def execute_test
          @re_test_count.times do |i|
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
