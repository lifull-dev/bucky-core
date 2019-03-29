# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/verifications/js_error_checker'

describe Bucky::TestEquipment::Verifications::JsErrorChecker do
  include Bucky::TestEquipment::Verifications::JsErrorChecker

  let(:driver) { double('driver') }
  before do
    allow(driver).to receive(:execute_script).and_return(actual_error)
  end

  describe 'assert_no_js_error' do
    context 'js_errors is not empty' do
      let(:actual_error) { 'execute_script' }
      it 'raise exception' do
        expect { assert_no_js_error(driver) }.to raise_error Test::Unit::AssertionFailedError
      end
    end

    context 'js_errors is empty' do
      let(:actual_error) { [] }
      it 'not raise execption' do
        expect { assert_no_js_error(driver) }.not_to raise_error
      end
    end
  end
end
