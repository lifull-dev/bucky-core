# frozen_string_literal: true

require_relative '../../utils/yaml_load'
require_relative '../../core/exception/bucky_exception'
require 'English'

module Bucky
  module TestEquipment
    module PageObject
      class BasePageObject
        include Bucky::Utils::YamlLoad

        # https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/SearchContext.html#find_element-instance_method
        FINDERS = {
          class: 'class name',
          class_name: 'class name',
          css: 'css selector',
          id: 'id',
          link: 'link text',
          link_text: 'link text',
          name: 'name',
          partial_link_text: 'partial link text',
          tag_name: 'tag name',
          xpath: 'xpath'
        }.freeze

        def initialize(service, device, page_name, driver)
          @driver = driver
          generate_parts(service, device, page_name)
        end

        private

        # Load parts file and define parts method
        # @param [String] service
        # @param [String] device (pc, sp)
        # @param [String] page_name
        def generate_parts(service, device, page_name)
          Dir.glob("./services/#{service}/#{device}/parts/#{page_name}.yml").each do |file|
            parts_data = load_yaml(file)

            # Define part method e.g.) page.parts
            parts_data.each do |part_name, value|
              self.class.class_eval { define_method(part_name) { find_elem(value[0], value[1]) } }
            end
          end
        end

        # @param [String] method Method name for searching WebElement
        #   http://www.rubydoc.info/gems/selenium-webdriver/0.0.28/Selenium/WebDriver/Find
        # @param [String] Condition of search (xpath/id)
        # @return [Selenium::WebDriver::Element]
        def find_elem(method, value)
          method_name = method.downcase.to_sym
          raise StandardError, "Invalid finder. #{method_name}" unless FINDERS.key? method_name

          wait = Selenium::WebDriver::Wait.new(timeout: 3, interval: 0.1, ignore: [Selenium::WebDriver::Error::NoSuchElementError])
          # wait until driver find element
          elements = wait.until { @driver.find_elements(method_name, value) }
          raise_if_elements_empty(elements, method_name, value)
          elements.first.instance_eval { define_singleton_method('[]') { |num| elements[num] } }
          elements.first
        rescue Selenium::WebDriver::Error::TimeoutError
          raise Selenium::WebDriver::Error::NoSuchElementError, "Exceeded the limit times for find_elements.\n   #{$ERROR_INFO.message}"
        rescue StandardError => e
          Bucky::Core::Exception::WebdriverException.handle(e)
        end

        def raise_if_elements_empty(elements, method, value)
          raise Selenium::WebDriver::Error::NoSuchElementError, "#{method} #{value}" if elements.empty?
        end
      end
    end
  end
end
