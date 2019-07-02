# frozen_string_literal: true

module Bucky
  module TestEquipment
    module UserOperation
      class UserOperationHelper
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
          wait = Selenium::WebDriver::Wait.new(:timeout => 5, :interval => 0.1, :ignore => [Selenium::WebDriver::Error::WebDriverError])
          begin
            # it will return nil if click successfully
            wait.until{ elem.click.nil? }
          rescue Selenium::WebDriver::Error::TimeoutError
            raise Selenium::WebDriver::Error::TimeoutError, "Exceeded the limit for trying to click.\n    #{$ERROR_INFO.message}"
          end
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
          # change ignore condition, NoSuchElementError to NoSuchWindowError
          wait = Selenium::WebDriver::Wait.new(:timeout => 1, :interval => 0.1, :ignore => [Selenium::WebDriver::Error::NoSuchWindowError])
          begin
            # when the window successfully switched, return of switch_to.window is nil.
            wait.until{ @driver.switch_to.window(args[:window_name]).nil? }
          rescue Selenium::WebDriver::Error::TimeoutError
            raise Selenium::WebDriver::Error::TimeoutError, "Exceeded the limit for trying switch_to_the_window.\n    #{$ERROR_INFO.message}"
          end
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
          option = Selenium::WebDriver::Support::Select.new(@pages.get_part(args))
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
          a = @driver.switch_to.alert
          a.accept
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
