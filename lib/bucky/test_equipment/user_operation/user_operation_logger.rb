# frozen_string_literal: true

module Bucky
  module TestEquipment
    module UserOperation
      class UserOperationLogger
        class << self
          def get_user_opr_log(op_args)
            op_args.to_s << "\n"
          end
        end
      end
    end
  end
end
