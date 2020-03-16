# frozen_string_literal: true

require_relative '../../core/exception/bucky_exception'
require_relative './user_operation_helper'
require_relative '../../utils/bucky_logger'

module Bucky
  module TestEquipment
    module UserOperation
      class UserOperator
        include Bucky::Utils::BuckyLogger

        def initialize(args)
          @operation_helper = Bucky::TestEquipment::UserOperation::UserOperationHelper.new(args)
          @pages = args[:pages]
        end

        # Call user operation by argument
        # @param [String] operation
        # @param [String] test_case_name
        # @param [Hash] args
        def method_missing(operation, test_case_name, **args)
          @operation = operation
          @test_case_name = test_case_name
          Bucky::Utils::BuckyLogger.write(test_case_name, args[:exec])

          # Call method of UserOperationHelper
          return @operation_helper.send(@operation, args[:exec]) if @operation_helper.methods.include?(@operation)

          # Call method of page object
          # e.g) {page: 'top', operation: 'input_freeword', word: 'testing word'}
          return page_method(args[:exec]) if args[:exec].key?(:page) && !args[:exec].key?(:part)

          # Call method of part
          part_mothod(args[:exec]) if args[:exec].key?(:part)
        rescue StandardError => e
          Bucky::Core::Exception::WebdriverException.handle(e, "#{args[:step_number]}:#{args[:proc_name]}")
        end

        private

        def page_method(args)
          @pages.send(args[:page]).send(@operation, args)
        end

        def part_mothod(args)
          # Multiple parts is saved as hash
          # e.g){page: 'top', part: {locate: 'rosen_tokyo', num: 1}, operate: 'click'}
          if args[:part].class == Hash
            part_name = args[:part][:locate]
            num = args[:part][:num]
            @pages.send(args[:page]).send(part_name)[num].send(@operation)
          # e.g.){page: 'top', part: 'rosen_tokyo', operate: 'click'}
          else
            @pages.send(args[:page]).send(args[:part]).send(@operation)
          end
        end
      end
    end
  end
end
