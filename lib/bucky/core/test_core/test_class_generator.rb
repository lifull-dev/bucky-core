# frozen_string_literal: true

require_relative '../../test_equipment/test_case/e2e_test_case'
require_relative '../../test_equipment/test_case/linkstatus_test_case'

module Bucky
  module Core
    module TestCore
      # For creating class dynamically.
      class TestClasses
      end

      module TestClassGeneratorHelper
        private

        def add_test_procedure(procedures)
          procedures.each.with_index(1) do |procedure, index|
            puts procedure[:proc].insert(0, "  #{index}:") if procedure.key?(:proc)
            method = procedure[:exec].key?(:operate) ? :operate : :verify
            send(method, procedure)
          end
        end

        def make_test_method_name(data, test_case, index)
          if test_case[:case_name].nil?
            return [
              'test',
              data[:suite][:service],
              data[:suite][:device],
              data[:test_category],
              data[:test_suite_name],
              index.to_s
            ].join('_')
          end
          "test_#{test_case[:case_name]}"
        end
      end

      class TestClassGenerator
        attr_accessor :test_classes

        def initialize(test_cond)
          @test_classes = TestClasses
          @test_cond = test_cond
        end

        # Genrate test class by test suite and test case data
        def generate_test_class(data, link_status_url_log = {})
          test_cond = @test_cond
          # Common proccessing
          # e.g.) TestSampleAppPcE2e1, TestSampleAppPcHttpstatus1
          test_class_name = make_test_class_name(data)
          # Select super class by test category
          super_suite_class = eval format('Bucky::TestEquipment::TestCase::%<test_category>sTestCase', test_category: data[:test_category].capitalize)
          # Define test suite class
          test_classes.const_set(test_class_name.to_sym, Class.new(super_suite_class) do |_klass|
            extend TestClassGeneratorHelper
            include TestClassGeneratorHelper
            define_method(:suite_data, proc { data[:suite] })
            define_method(:suite_id, proc { data[:test_suite_id] })
            define_method(:simple_test_class_name) do |original_name|
              match_obj = /\Atest_(.+)\(.+::(Test.+)\)\z/.match(original_name)
              "#{match_obj[1]}(#{match_obj[2]})"
            end

            # Class structure is different for each test category
            case data[:test_category]
            when 'linkstatus' then
              data[:suite][:cases].each_with_index do |t_case, i|
                method_name = make_test_method_name(data, t_case, i)
                description(
                  t_case[:case_name],
                  define_method(method_name) do
                    puts "\n#{simple_test_class_name(name)}"
                    t_case[:urls].each do |url|
                      link_status_check_args = { url: url, device: data[:suite][:device], exclude_urls: data[:suite][:exclude_urls], link_check_max_times: test_cond[:link_check_max_times], url_log: link_status_url_log }
                      link_status_check(link_status_check_args)
                    end
                  end
                )
              end

            when 'e2e' then
              if data[:suite][:setup_each]
                def setup
                  super
                  puts "[setup]#{simple_test_class_name(name)}"
                  add_test_procedure(suite_data[:setup_each][:procs])
                end
              end

              if data[:suite][:teardown_each]
                def teardown
                  puts "[teardown]#{simple_test_class_name(name)}"
                  add_test_procedure(suite_data[:teardown_each][:procs])
                  super
                end
              end

              # Generate test case method
              data[:suite][:cases].each_with_index do |t_case, i|
                # e.g.) test_sample_app_pc_e2e_1_2
                method_name = make_test_method_name(data, t_case, i)
                method_obj = proc do
                  puts "\n#{simple_test_class_name(name)}\n #{t_case[:desc]} ...."
                  add_test_procedure(t_case[:procs])
                end
                description(t_case[:case_name], define_method(method_name, method_obj))
              end
            end
          end)
        end

        private

        def make_test_class_name(data)
          [
            'Test',
            data[:suite][:service].split(/_|-/).map(&:capitalize).join.to_s,
            data[:suite][:device].capitalize.to_s,
            data[:test_category].to_s.capitalize.to_s,
            (data[:test_class_name]).to_s
          ].join
        end
      end
    end
  end
end
