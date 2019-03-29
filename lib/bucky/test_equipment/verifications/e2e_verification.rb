# frozen_string_literal: true

require_relative '../../utils/bucky_logger'
require_relative '../../utils/bucky_output'
require_relative './abst_verification'
require_relative '../evidence/evidence_generator'

module Bucky
  module TestEquipment
    module Verifications
      class E2eVerification < Bucky::TestEquipment::Verifications::AbstVerification
        include Bucky::Utils::BuckyLogger
        include Bucky::Utils::BuckyOutput
        using StringColorize

        def initialize(driver, pages, test_case_name)
          @driver = driver
          @pages = pages
          @evidence = Bucky::TestEquipment::Evidence::E2eEvidence.new(driver: driver, test_case: test_case_name)
        end

        def pages_getter
          @pages
        end

        # Check whether title of web page matches expected value
        # @param [Hash]
        def assert_title(**args)
          Bucky::Utils::BuckyLogger.write('assert_title', args)
          verify_rescue { assert_equal(args[:expect]&.to_s, @driver.title, 'Not Expected Title.') }
        end

        # Check whether text of web element matches expected value
        # @param [Hash]
        def assert_text(**args)
          Bucky::Utils::BuckyLogger.write('assert_text', args)
          part = @pages.get_part(args)
          verify_rescue { assert_equal(args[:expect]&.to_s, part.text, 'Not Expected Text.') }
        end

        # Check whether text of web element contains expected value
        # @param [Hash]
        def assert_contained_text(**args)
          Bucky::Utils::BuckyLogger.write('assert_contained_text', args)
          part = @pages.get_part(args)
          verify_rescue { assert(part.text.include?(args[:expect]&.to_s), "Not Contain Expected Text.\nexpect: #{args[:expect].to_s.bg_green.black}\nactual: #{part.text.to_s.bg_red.black}") }
        end

        # Check whether url contains excepted value
        # @param [Hash]
        def assert_contained_url(**args)
          Bucky::Utils::BuckyLogger.write('assert_contained_url', args)
          verify_rescue { assert(@driver.current_url.include?(args[:expect]&.to_s), "Not Contain Expected URL.\nexpect:  #{args[:expect].to_s.bg_green.black}\nactual: #{@driver.current_url.to_s.bg_red.black}") }
        end

        # Check whether attribute of web element contains excepted value.
        # @param [Hash]
        def assert_contained_attribute(**args)
          Bucky::Utils::BuckyLogger.write('assert_contained_attribute', args)
          part = @pages.get_part(args)
          verify_rescue { assert(part[args[:attribute]].include?(args[:expect]&.to_s), "Not Contain Expected Attribute.\nexpect: #{args[:expect].to_s.bg_green.black}\nactual: #{part[args[:attribute]].to_s.bg_red.black}") }
        end

        # Check whether text of part is number
        # @param [Hash]
        def assert_is_number(**args)
          Bucky::Utils::BuckyLogger.write('assert is number', args)
          text = @pages.get_part(args).text.sub(',', '')
          verify_rescue { assert(text.to_i.to_s == text.to_s, "Not number.\nactual: #{text.bg_red.black}") }
        end

        # Check whether style property includes display:block
        # @param [Hash]
        def assert_display(**args)
          Bucky::Utils::BuckyLogger.write('assert display', args)
          verify_rescue { assert_true(@pages.get_part(args).displayed?, "No display this parts.\nURL: #{@driver.current_url}\npage: #{args[:page]}\npart: #{args[:part]}") }
        end

        # Check whether web element exists
        # @param [Hash]
        def assert_exist_part(**args)
          Bucky::Utils::BuckyLogger.write('assert_exist_part', args)
          verify_rescue { assert_true(@pages.part_exist?(args), "This part is not exist.\nURL: #{@driver.current_url}\npage: #{args[:page]}\npart: #{args[:part]}") }
        end

        # Check whether web element don't exist
        # @param [Hash]
        def assert_not_exist_part(**args)
          Bucky::Utils::BuckyLogger.write('assert_not_exist_part', args)
          verify_rescue { assert_false(@pages.part_exist?(args), "This part is exist.\nURL: #{@driver.current_url}\npage: #{args[:page]}\npart: #{args[:part]}") }
        end

        private

        # Common exception method
        # @param [Method] &assert
        def verify_rescue
          yield
        rescue StandardError => e
          @evidence.save_evidence(e)
          raise e
        end
      end
    end
  end
end
