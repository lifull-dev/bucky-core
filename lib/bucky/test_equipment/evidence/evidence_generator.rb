# frozen_string_literal: true

require_relative '../../core/report/screen_shot_generator'
require_relative '../../utils/bucky_logger'

module Bucky
  module TestEquipment
    module Evidence
      class EvidenceGenerator
        include Bucky::Utils::BuckyLogger

        # Save log
        # @param [String] file
        # @param [Exception Object] err
        def report(file, err)
          Bucky::Utils::BuckyLogger.write(file, err)
        end
      end

      # Create evidence for each test category
      class E2eEvidence < EvidenceGenerator
        include Bucky::Core::Report::ScreenShotGenerator

        def initialize(**evid_args)
          @driver = evid_args[:driver]
          @tc = evid_args[:test_case]
        end

        def save_evidence(err)
          generate_screen_shot(@driver, @tc)
          report("#{@tc}_error", err)
        end
      end
    end
  end
end
