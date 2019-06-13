# frozen_string_literal: true

require 'parallel'
require_relative '../test_core/test_case_loader'
require_relative '../../utils/config'
require_relative './test_class_generator'

module Bucky
  module Core
    module TestCore
      class TestManager
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
          parallel_num = Bucky::Utils::Config.instance[:parallel_num]
          parallel_helper(test_suite_data, parallel_num)
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

        def parallel_helper(test_suite_data, max_processes)
          # Max parallel processed to run
          processes_counter = max_processes
          # For checking on linkstatus
          link_status_url_log = {}
          parent_pid = Process.pid
          tcg = Bucky::Core::TestCore::TestClassGenerator.new(@test_cond)

          # Check if child process dead
          Signal.trap('CLD') { processes_counter += 1 }
          # Terminate parent and child process when getting interrupt signal
          Signal.trap('INT') do
            Process.kill('TERM', -1 * parent_pid)
          end

          test_suite_data.each do |data|
            Process.wait unless processes_counter.positive?
            processes_counter -= 1
            fork { tcg.generate_test_class(data, link_status_url_log) }
          end
          Process.waitall
        end
      end
    end
  end
end
