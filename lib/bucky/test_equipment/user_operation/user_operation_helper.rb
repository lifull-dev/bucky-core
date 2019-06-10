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
          sleep 1
          elem.click
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

        def switch_the_window(args)
          sleep 1
          @driver.swich_to_window_by_name(args[:window_name])
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
