# frozen_string_literal: true

require_relative '../../utils/yaml_load'
require_relative '../../core/exception/bucky_exception'

module Bucky
  module TestEquipment
    module PageObject
      class BasePageObject
        include Bucky::Utils::YamlLoad

        # https://www.rubydoc.info/gems/selenium-webdriver/2.53.0/Selenium/WebDriver/SearchContext#find_elements-instance_method
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
        # @param [String] paga_name
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
          raise StandardError, "Invalid finder. #{method}" unless FIDERS.key? method.to_sym

          elem = @driver.find_elements(method.to_sym, value)
          raise_if_element_empty(elem, method, value)
        rescue StandardError => e
          Bucky::Core::Exception::WebdriverException.handle(e)
        end

        def raise_if_element_empty(elem, method, value)
          raise Selenium::WebDriver::Error::NoSuchElementError, "#{method} #{value}" if elem.empty?
        end
      end
    end
  end
end
