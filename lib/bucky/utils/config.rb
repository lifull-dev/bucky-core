# frozen_string_literal: true

require 'singleton'
require_relative './yaml_load'

module Bucky
  module Utils
    class Config
      include Bucky::Utils::YamlLoad
      include Singleton
      @@dir = "#{$bucky_home_dir}/config/**/*yml"

      # @param [String] *.yml or hoge/fuga.yml
      def initialize
        @data = {}
        @resources = []

        # Read from a file of shallow hierarchy, then overwrite it if there is same key in deep hierarchy
        file_sort_hierarchy(@@dir).each do |file|
          data = load_yaml(file)
          unless data.empty?
            @data = @data.merge(data)
            @resources << file
          end
        end

        set_selenium_ip
      end

      # @return [Hash] loaded data
      def data
        @data || {}
      end

      # Get data by []
      def [](column)
        return data[column] if data.key?(column)

        # If there is no key, raise exeption
        raise "Undefined Config : #{column}\nKey doesn't match in config file. Please check config file in config/*"
      end

      private

      def set_selenium_ip
        return unless @data[:selenium_ip] == 'docker_host_ip'

        selenium_ip = `ip route | awk 'NR==1 {print $3}'`.chomp
        raise StandardError, 'Could not load docker host ip.' if selenium_ip.empty?

        @data[:selenium_ip] = selenium_ip
      end
    end
  end
end
