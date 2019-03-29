# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/test_case/e2e_test_case'

describe Bucky::TestEquipment::TestCase::E2eTestCase do
  Test::Unit::AutoRunner.need_auto_run = false
  let(:this_class) { Bucky::TestEquipment::TestCase::E2eTestCase }
  subject { this_class.new('test_method_name') }

  before do
    allow(subject).to receive(:suite_data).and_return(service: 'service_a', device: 'pc')
  end

  describe '#t_equip_setup' do
    it 'call create_webdriver' do
      allow(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      allow(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new)
      allow(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new)
      expect(subject).to receive(:create_webdriver)
      subject.t_equip_setup
    end
    it 'create instance of Bucky::TestEquipment::PageObject::Pages' do
      allow(subject).to receive(:create_webdriver)
      allow(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new)
      allow(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new)
      expect(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      subject.t_equip_setup
    end
    it 'create instance of Bucky::TestEquipment::UserOperation::UserOperator' do
      allow(subject).to receive(:create_webdriver)
      allow(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new)
      allow(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      expect(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new)
      subject.t_equip_setup
    end
    it 'create instance of Bucky::TestEquipment::Verifications::ServiceVerifications' do
      allow(subject).to receive(:create_webdriver)
      allow(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      allow(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new)
      expect(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new)
      subject.t_equip_setup
    end
  end

  describe '#verify' do
    let(:verification_double) { double('verification double') }
    before do
      allow(subject).to receive(:create_webdriver)
      allow(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new).and_return(verification_double)
      allow(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      allow(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new)
      subject.t_equip_setup
    end
    it 'call service_verifications.send' do
      expect(verification_double).to receive(:send)
      subject.verify
    end
  end

  describe '#operate' do
    let(:user_operator_double) { double('user_operator double') }
    before do
      allow(subject).to receive(:create_webdriver)
      allow(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new)
      allow(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      allow(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new).and_return(user_operator_double)
      allow(Bucky::TestEquipment::Verifications::E2eVerification).to receive(:new)
      subject.t_equip_setup
    end
    it 'call user_operator.send' do
      expect(user_operator_double).to receive(:send)
      subject.operate
    end
  end

  describe '#check_js_error' do
    before do
      this_class.class_variable_set :@@config, js_error_check: js_error_check?
    end
    context 'when use js error check' do
      let(:js_error_check?) { true }
      it 'call assert_no_js_error' do
        expect(subject).to receive(:assert_no_js_error)
        subject.check_js_error
      end
    end
    context 'when not use js error check' do
      let(:js_error_check?) { false }
      it 'not call assert_no_js_error' do
        expect(subject).not_to receive(:assert_no_js_error)
        subject.check_js_error
      end
    end
  end
  describe '#setup' do
    it 'call t_equip_setup' do
      expect(subject).to receive(:t_equip_setup)
      subject.setup
    end
  end
  describe '#teardown' do
    # Not implement, because implementing super mock is difficault
  end
end
