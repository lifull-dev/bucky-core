# frozen_string_literal: true

require_relative '../../utils/bucky_logger'
require_relative '../../utils/config'

module Bucky
  module Core
    module Exception
      class BuckyException
        include Bucky::Utils::BuckyLogger
        class << self
          # Error handling on bucky framework
          # @param [Object] err exception object
          def handle(err)
            Bucky::Utils::BuckyLogger.write(Bucky::Utils::Config.instance[:bucky_error], err)
          end
        end
      end

      class DbConnectorException < Bucky::Core::Exception::BuckyException
        class << self
          def handle(err)
            super
            raise err
          end
        end
      end

      class WebdriverException < Bucky::Core::Exception::BuckyException
        class << self
          def handle(err)
            super
            raise err
          end
        end
      end
    end
  end
end
