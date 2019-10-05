# frozen_string_literal: true

require 'singleton'

module Bucky
  module Core
    module TestCore
      class ExitHandler
        include Singleton

        @@exit_code = 0

        def self.reset
            @@exit_code = 0
        end

        def self.raise
            @@exit_code = 1
        end

        def self.bucky_exit
            p @@exit_code
        end
      end
    end
  end
end
