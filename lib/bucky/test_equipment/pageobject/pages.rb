# frozen_string_literal: true

module Bucky
  module TestEquipment
    module PageObject
      class Pages
        def initialize(service, device, driver)
          collect_pageobjects(service, device, driver)
        end

        # Load page class and define page method
        # @param [String] service
        # @param [String] device (pc, sp)
        # @param [Object] driver Webdriver object
        def collect_pageobjects(service, device, driver)
          # Create module name
          module_service_name = service.split('_').map(&:capitalize).join
          Dir.glob("#{$bucky_home_dir}/services/#{service}/#{device}/pageobject/*.rb").each do |file|
            require file

            page_name = file.split('/')[-1].sub('.rb', '')
            page_class_name = page_name.split('_').map(&:capitalize).join

            # Get instance of page class
            page_class = eval(format('Services::%<module_service_name>s::%<device>s::PageObject::%<page_class_name>s', module_service_name: module_service_name, device: device.capitalize, page_class_name: page_class_name))
            page_instance = page_class.new(service, device, page_name, driver)

            # Define method by page name
            self.class.class_eval do
              define_method(page_name) { page_instance }
            end
          end
        end

        # Get Web element by page, part, num
        # @param [Hash] args
        def get_part(args)
          return send(args[:page]).send(args[:part][:locate])[args[:part][:num]] if part_plural?(args)

          send(args[:page]).send(args[:part]).first
        end

        # @param [Hash] args
        # @return [Boolean]
        def part_plural?(args)
          # If the part is hash and has 'num' key, it has plural elements.
          args[:part].class == Hash && args[:part].key?(:num)
        end

        # @param [Hash] args
        # @return [Bool]
        def part_exist?(args)
          get_part(args)
          true
        rescue Selenium::WebDriver::Error::NoSuchElementError
          false
        end
      end
    end
  end
end
