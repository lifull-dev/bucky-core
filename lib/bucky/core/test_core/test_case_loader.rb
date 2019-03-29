# frozen_string_literal: true

require_relative '../database/test_data_operator'
require_relative '../../utils/yaml_load'

class Hash
  def deep_symbolize_keys!
    deep_transform_keys! do |key|
      key unless key.respond_to? :to_sym
      key.to_sym
    end
  end

  def deep_transform_keys!(&block)
    keys.each do |key|
      value = delete(key)
      self[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys!(&block) : value
    end
    self
  end
end

module Bucky
  module Core
    module TestCore
      class TestCaseLoader
        class << self
          include Bucky::Utils::YamlLoad
          # Load test code files and return test suite data.
          # @return [Array] test suite
          def load_testcode(test_cond)
            return load_re_test_testcode(test_cond[:re_test_cond]) if test_cond.key? :re_test_cond

            testcodes = []
            service = (test_cond[:service] || ['*']).first
            device = (test_cond[:device] || ['*']).first
            category = (test_cond[:test_category] || ['*']).first

            Dir.glob("#{$bucky_home_dir}/services/#{service}/#{device}/scenarios/#{category}/*.yml").each do |testcode_file|
              testcodes << load_testcode_in_file(testcode_file, test_cond)
            end
            # Delete nil element
            testcodes.compact
          end

          private

          def load_testcode_in_file(testcode_file, test_cond)
            testcode_info = testcode_file.split(%r{/|\.}).reverse
            test_suite_name, test_category = testcode_info[1..3]
            test_class_name = test_suite_name.split('_').map(&:capitalize).join
            test_suite = load_suite_file(testcode_file)
            return nil unless target_in_suite_options?(test_suite, test_cond, test_suite_name)

            test_suite = set_suite_option_to_case(test_suite)
            refined_suite = refine_case_with_option(test_cond, test_suite)
            return nil if refined_suite[:cases].empty?

            { test_class_name: test_class_name, test_suite_name: test_suite_name, test_category: test_category, suite: refined_suite }
          end

          def load_re_test_testcode(re_test_cond)
            testcodes = []
            re_test_cond.each_value do |cond|
              testcode_info = cond[:file_path].split(%r{/|\.}).reverse
              test_suite_name, test_category = testcode_info[1..3]
              test_class_name = test_suite_name.split('_').map(&:capitalize).join
              test_suite = load_suite_file(cond[:file_path])
              test_suite[:cases].delete_if { |c| !cond[:case_names].include? c[:case_name] }
              testcodes << { test_class_name: test_class_name, test_suite_name: test_suite_name, test_category: test_category, suite: test_suite }
            end
            testcodes
          end

          def load_suite_file(file)
            test_suite = load_yaml(file)
            test_suite.deep_symbolize_keys!
            test_suite[:setup_each][:procs].each(&:deep_symbolize_keys!) if test_suite[:setup_each]
            test_suite[:teardown_each][:procs].each(&:deep_symbolize_keys!) if test_suite[:teardown_each]
            test_suite[:cases].each do |c|
              c.deep_symbolize_keys!
              next unless c.key? :procs

              c[:procs].each do |p|
                c[:procs].delete(p) unless when_match?(p)
                p.deep_symbolize_keys!
              end
            end
            test_suite
          rescue StandardError => ex
            raise ex, "loading #{file}, #{ex.message}"
          end

          def when_match?(proc)
            return true unless proc.key?('when')
            raise StandardError, 'Please input correct condition' unless [true, false].include?(proc['when'])

            proc['when']
          end

          # Return true if match suite condition
          # Only priority and suite name
          def target_in_suite_options?(test_suite, test_cond, test_suite_name)
            # priority
            return false unless check_option_include_target?(test_cond[:priority], test_suite[:priority])
            # suite_name
            return false unless check_option_include_target?(test_cond[:suite_name], test_suite_name)

            true
          end

          # Return true, if target includes specified option
          def check_option_include_target?(option, target)
            # If there is no option, return nil.
            if option.nil?
              nil
            else
              return false unless option.include?(target)
            end
            true
          end

          # set suite option to case e.g.) suite's labels are inherited by test cases
          # only label
          def set_suite_option_to_case(test_suite)
            return test_suite unless test_suite.key?(:labels)

            # Pattern of value is different depending on how to write (string/array)
            # change to array on all pattern
            test_suite[:labels] = [test_suite[:labels]].flatten
            test_suite[:cases].each do |c|
              c[:labels] = if c.key?(:labels)
                             [c[:labels]].flatten | test_suite[:labels]
                           else
                             test_suite[:labels]
                           end
            end
            test_suite
          end

          # Filter with option
          def refine_case_with_option(test_cond, suite)
            # Filtering by label
            if test_cond.key? :label
              # Delete test case that have no label
              # Pattern of value is different depending on how to write (string/array)
              # Change to array on all pattern
              suite[:cases].delete_if { |c| c[:labels].nil? }
              suite[:cases].delete_if { |c| !(test_cond[:label].sort - [c[:labels]].flatten.sort).empty? }
            end
            # If there is no option, do nothing.
            return suite unless test_cond.key? :case

            # Delete test case doesn't match
            suite[:cases].delete_if { |c| !test_cond[:case].include? c[:case_name] }
            suite
          end
        end
      end
    end
  end
end
