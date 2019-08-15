# frozen_string_literal: true
require_relative '../utils/yaml_load'

module Bucky
  module Tools
    class Lint
      class << self
        include Bucky::Utils::YamlLoad
        @@config_dir = "#{$bucky_home_dir}/config/**/*yml"
        @@rule_config_dir = File.expand_path('../../../template/new/config', __dir__) + '/*yml'

        def check(category)
          method = "check_#{category}".to_sym
          respond_to?(method) ? send(method) : raise(StandardError, "no such a category #{category}")
        end

        # If you want to add new category, please make new method
        def check_config
          data = merge_yaml_data(@@config_dir)
          @rule_data = merge_yaml_data(@@rule_config_dir)
          actual = make_key_chain(data)
          expect = make_key_chain(@rule_data)
          diff = diff_arr(expect, actual)
          make_message(diff)
        end

        private

        # Merge yaml in target directory.
        def merge_yaml_data(dir)
          data_output = {}
          file_sort_hierarchy(dir).each do |file|
            data = load_yaml(file)
            data_output.merge!(data) unless data.empty?
          end
          data_output.any? ? data_output : (raise StandardError, "No key! please check the directory existence [#{dir}]")
        end

        def make_message(diff)
          if diff.empty?
            puts "\e[32mok\e[0m"
          else
            puts "\e[31m[ERROR] The following configures are undefined. Tests can still be executed with default value automatically."
            diff.each do |key|
              puts "- #{key}"
              puts "{#{key}: #{@rule_data[:"#{key}"]}}\e[0m"
            end
          end
        end

        def diff_arr(expect, actual)
          expect.delete_if do |i|
            actual.include?(i)
          end
        end

        def make_key_chain(hash)
          hash.map do |k, v|
            if v.is_a? Hash
              make_key_chain(v).map { |item| "#{k}-#{item}" }
            else
              k.to_s
            end
          end.flatten
        end
      end
    end
  end
end
