# frozen_string_literal: true

module Bucky
  module Utils
    module BuckyOutput
      module StringColorize
        refine String do
          def black
            "\e[30m#{self}\e[0m"
          end

          def bg_red
            "\e[41m#{self}\e[0m"
          end

          def bg_green
            "\e[42m#{self}\e[0m"
          end
        end
      end
    end
  end
end
