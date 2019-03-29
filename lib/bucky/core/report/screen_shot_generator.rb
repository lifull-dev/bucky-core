# frozen_string_literal: true

require_relative '../../utils/config'
require_relative '../exception/bucky_exception'

module Bucky
  module Core
    module Report
      module ScreenShotGenerator
        # Save screen shot
        # @param [Webdriver] driver
        # @param [String] test_case e.g.) test_sample_app_pc_e2e_1_1
        def generate_screen_shot(driver, test_case)
          timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
          driver.save_screenshot(
            Bucky::Utils::Config.instance[:screen_shot_path] + test_case << "_#{timestamp}.png"
          )
        rescue StandardError => e
          Bucky::Core::Exception::BuckyException.handle(e)
        end
      end
    end
  end
end
