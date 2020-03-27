# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/user_operation/user_operation_logger'

describe Bucky::TestEquipment::UserOperation::UserOperationLogger do
  subject { Bucky::TestEquipment::UserOperation::UserOperationLogger }

  describe '.get_user_opr_log' do
    let(:operation_args) { { operation: :go } }
    it 'change to string' do
      expect(subject.get_user_opr_log(operation_args)).to be_a_kind_of(String)
    end
  end
end
