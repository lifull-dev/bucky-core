# frozen_string_literal: true

require 'singleton'

module Bucky
  module Core
    module TestCore
      class ExitHandler
        include Singleton
        attr_accessor :exit_code

        def initialize
          @exit_code = 0
        end

        def reset
          @exit_code = 0
        end

        def bucky_exit
          p @exit_code
          # exit @exit_code
        end
      end
    end
  end
end