# frozen_string_literal: true

require_relative '../verifications/e2e_verification'

module Bucky
  module TestEquipment
    module Verifications
      class ServiceVerifications
        attr_reader :e2e_verification

        # @param [String] @service
        # @param [String] @device (pc, sp)
        # @param [Selenium::WebDriver::Remote::Driver] @driver
        # @param [Bucky::TestEquipment::PageObject::Pages] @pages
        # @param [String] @test_case_name
        def initialize(args)
          @service = args[:service]
          @device = args[:device]
          @driver = args[:driver]
          @pages = args[:pages]
          @test_case_name = args[:method_name]
          collect_verifications
          @e2e_verification = Bucky::TestEquipment::Verifications::E2eVerification.new(@driver, @pages, @test_case_name)
        end

        def method_missing(verification, **args)
          if e2e_verification.respond_to? verification
            puts "    #{verification} is defined in E2eVerificationClass."
            e2e_verification.send(verification, args[:exec])
          elsif args[:exec].key?(:page)
            send(args[:exec][:page]).send(verification, args[:exec])
          else
            raise StandardError, "Undefined verification method or invalid arguments. #{verification},#{args[:exec]}"
          end
        rescue StandardError => e
          raise e
        end

        private

        # Load page and define page verification method
        def collect_verifications
          module_service_name = @service.split('_').map(&:capitalize).join
          Dir.glob("#{$bucky_home_dir}/services/#{@service}/#{@device}/verifications/*.rb").each do |file|
            require file

            page_name = file.split('/')[-1].sub('.rb', '')
            page_class_name = page_name.split('_').map(&:capitalize).join

            # Get instance of page object
            page_class = eval(format('Services::%<module_service_name>s::%<device>s::Verifications::%<page_class_name>s', module_service_name: module_service_name, device: @device.capitalize, page_class_name: page_class_name))
            page_instance = page_class.new(@driver, @pages, @test_case_name)

            self.class.class_eval do
              define_method(page_name) { page_instance }
            end
          end
        end
      end
    end
  end
end
