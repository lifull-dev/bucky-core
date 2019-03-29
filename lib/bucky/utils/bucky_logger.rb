# frozen_string_literal: true

require 'logger'
require_relative './config'

module Bucky
  module Utils
    module BuckyLogger
      LogFileDir = Bucky::Utils::Config.instance.data[:log_path]
      # Write following logs
      # - user opareation (e.g. test_sample_app_pc_e2e_1_1.log)
      # - verification (e.g. test_sample_app_pc_e2e_1_1.log)
      # - Error of Bucky core (bucky_error.log)
      # @param [String] file_name
      # @param [String] or [Execption] content
      def write(file_name, content)
        puts "    #{content}"
        logger = Logger.new("#{LogFileDir}#{file_name}.log", 1)
        logger.info content
        logger.close
      end
      module_function :write
    end
  end
end
