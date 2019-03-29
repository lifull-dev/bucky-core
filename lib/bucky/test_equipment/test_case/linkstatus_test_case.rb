# frozen_string_literal: true

require 'net/http'
require_relative '../verifications/status_checker'
require_relative './abst_test_case'

module Bucky
  module TestEquipment
    module TestCase
      class LinkstatusTestCase < Bucky::TestEquipment::TestCase::AbstTestCase
        include Bucky::TestEquipment::Verifications::StatusChecker

        class << self
          def startup; end

          def shutdown; end
        end

        def setup; end

        def teardown
          # Call abst_test_case.teardown to get elappsed time of every test case
          super
        end
      end
    end
  end
end
