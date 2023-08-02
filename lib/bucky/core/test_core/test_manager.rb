# frozen_string_literal: true

require 'json'
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

          r_pipe, w_pipe = IO.pipe

          data_set.each do |data|
            # Wait until worker is available and handle exit code from previous process
            unless available_workers.positive?
              Process.wait
              Bucky::Core::TestCore::ExitHandler.instance.raise unless $CHILD_STATUS.exitstatus.zero?
            end
            # Workers decrease when start working
            available_workers -= 1
            fork { block.call(data, w_pipe) }
          end
          # Handle all exit code in waitall
          Process.waitall.each do |child|
            Bucky::Core::TestCore::ExitHandler.instance.raise unless child[1].exitstatus.zero?
          end

          w_pipe.close
          results_set = collect_results_set(r_pipe)
          r_pipe.close

          results_set
        end

        def parallel_distribute_into_workers(data_set, max_processes, &block)
          # Group the data by remainder of index
          data_set_grouped = data_set.group_by.with_index { |_elem, index| index % max_processes }
          r_pipe, w_pipe = IO.pipe
          # Use 'values' method to get only hash's key into an array
          data_set_grouped.values.each do |data_for_pre_worker|
            # Number of child process is equal to max_processes (or equal to data_set length when data_set length is less than max_processes)
            fork do
              data_for_pre_worker.each { |data| block.call(data, w_pipe) }
            end
          end
          # Handle all exit code in waitall
          Process.waitall.each do |child|
            Bucky::Core::TestCore::ExitHandler.instance.raise unless child[1].exitstatus.zero?
          end

          w_pipe.close
          results_set = collect_results_set(r_pipe)
          r_pipe.close

          results_set
        end

        def collect_results_set(r_pipe)
          results_set = {}
          r_pipe.each_line do |line|
            r = JSON.parse(line)
            results_set[r['test_class_name']] = r
          end

          results_set
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
          $job_id = @tdo.save_job_record_and_get_job_id(@start_time, @test_cond[:command_and_option], @test_cond[:base_fqdn])
          @json_report = {
            summary: {
              cases_count: 0,
              success_count: 0,
              failure_count: 0,
              job_id: $job_id,
              test_category: test_cond[:test_category],
              device: test_cond[:device],
              labels: test_cond[:label],
              exclude_labels: test_cond[:xlabel],
              rerun_job_id: test_cond[:job],
              round_count: 0
            }
          }
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
          case @test_cond[:test_category]
          when 'e2e' then results_set = parallel_new_worker_each(test_suite_data, e2e_parallel_num) { |data, w_pipe| tcg.generate_test_class(data: data, w_pipe: w_pipe) }
          when 'linkstatus' then
            linkstatus_url_log = {}
            results_set = parallel_distribute_into_workers(test_suite_data, linkstatus_parallel_num) { |data, w_pipe| tcg.generate_test_class(data: data, linkstatus_url_log: linkstatus_url_log, w_pipe: w_pipe) }
          end

          results_set
        end

        def execute_test
          all_round_results = []
          @re_test_count.times do |i|
            Bucky::Core::TestCore::ExitHandler.instance.reset
            $round = i + 1
            @json_report[:summary][:round_count] = $round
            test_suite_data = load_test_suites
            all_round_results.append(do_test_suites(test_suite_data))
            @test_cond[:re_test_cond] = @tdo.get_ng_test_cases_at_last_execution(
              is_error: 1, job_id: $job_id, round: $round
            )
            break if @test_cond[:re_test_cond].empty?
          end

          return unless @test_cond[:out]

          @json_report[:summary][:cases_count] = all_round_results[0].sum { |_case, res| res['cases_count'] }
          @json_report[:summary][:failure_count] = all_round_results[-1].sum { |_case, res| res['failure_count'] }
          @json_report[:summary][:success_count] = @json_report[:summary][:cases_count] - @json_report[:summary][:failure_count]

          File.open(@test_cond[:out], 'w') do |f|
            f.puts(@json_report.to_json)
            puts "\nSave report : #{@test_cond[:out]}\n"
          end
        end
      end
    end
  end
end
