# frozen_string_literal: true

require 'sequel'
require_relative '../exception/bucky_exception'
require_relative '../../utils/config'

module Bucky
  module Core
    module Database
      class DbConnector
        attr_reader :con
        def initialize
          @test_db_config = Bucky::Utils::Config.instance[:test_db]
        end

        # Connect to database
        # @param [String] db_name database name
        def connect(db_name = 'bucky_test')
          @con = Sequel.connect(@test_db_config[db_name.to_sym], encoding: 'utf8')
        end

        # Disconnect to database
        def disconnect
          @con.disconnect
        end
      end
    end
  end
end
