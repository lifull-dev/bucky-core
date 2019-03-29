# frozen_string_literal: true

require_relative '../../../lib/bucky/core/test_core/test_result'

describe Bucky::Core::TestCore::TestResult do
  let(:test_suite_result) { [{ test_case_1: 1.234 }, { test_case_2: 2.257 }] }
  let(:tdo_double) { double('double of Core::Database::TestDataOperator') }
  let(:instance) { Bucky::Core::TestCore::TestResult.instance }
  before :each do
    allow(Bucky::Core::Database::TestDataOperator).to receive(:new).and_return(tdo_double)
  end

  describe '#save' do
    it 'call test_data_operator#save_test_result' do
      allow(instance).to receive(:format_result_summary)
      expect(tdo_double).to receive(:save_test_result)
      instance.save(test_suite_result)
    end
  end
end
