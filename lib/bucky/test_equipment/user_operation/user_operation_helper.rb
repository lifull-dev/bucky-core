# frozen_string_literal: true

require_relative '../selenium_handler/wait_handler'

module Bucky
  module TestEquipment
    module UserOperation
      class UserOperationHelper
        include Bucky::TestEquipment::SeleniumHandler::WaitHandler

        def initialize(args)
          @app = args[:app]
          @device = args[:device]
          @driver = args[:driver]
          @pages  = args[:pages]
        end

        # Open url
        # @param [Hash]
        def go(args)
          @driver.navigate.to args[:url]
        end

        def back(_)
          @driver.navigate.back
        end

        def input(args)
          @pages.get_part(args).send_keys args[:word]
        end

        # Clear textbox
        def clear(args)
          @pages.get_part(args).clear
        end

        def click(args)
          elem = @pages.get_part(args)
          elem.location_once_scrolled_into_view
          # when click successfully, return of click is nil.
          wait_until_helper(5, 0.1, Selenium::WebDriver::Error::WebDriverError) { elem.click.nil? }
        end

        def refresh(_)
          @driver.navigate.refresh
        end

        def switch_next_window(_)
          @driver.switch_to.window(@driver.window_handles.last)
        end

        def back_to_window(_)
          @driver.switch_to.window(@driver.window_handles.first)
        end

        def switch_to_the_window(args)
          # when the window successfully switched, return of switch_to.window is nil.
          wait_until_helper(5, 0.1, Selenium::WebDriver::Error::NoSuchWindowError) { @driver.switch_to.window(args[:window_name]).nil? }
        end

        # Close window
        def close(_)
          @driver.close
        end

        def stop(_)
          puts 'stop. please enter to continue'
          gets
        end

        def choose(args)
          option = wait_until_helper(5, 0.1, Selenium::WebDriver::Error::StaleElementReferenceError) { Selenium::WebDriver::Support::Select.new(@pages.get_part(args)) }
          if args.key?(:text)
            type = :text
            selected = args[type].to_s
          elsif args.key?(:value)
            type = :value
            selected = args[type].to_s
          elsif args.key?(:index)
            type = :index
            selected = args[type].to_i
          else
            raise StandardError, "Included invalid key #{args.keys}"
          end
          option.select_by(type, selected)
        end

        # Alert accept
        def accept_alert(_)
          alert = wait_until_helper(5, 0.1, Selenium::WebDriver::Error::NoAlertPresentError) { @driver.switch_to.alert }
          alert.accept
        end

        def wait(args)
          # Indent
          print ' ' * 6
          args[:sec].times do |count|
            print "#{count + 1} "
            sleep 1
          end
          puts ''
        end
      end
    end
  end
end
