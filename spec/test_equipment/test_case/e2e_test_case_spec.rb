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
    let(:verify_args) { { exec: { verify: 'assert_title', expect: 'page title' }, step_number: 1, proc_name: 'test proc' } }
    before do
      allow(subject).to receive(:create_webdriver)
      allow(Bucky::TestEquipment::Verifications::ServiceVerifications).to receive(:new).and_return(verification_double)
      allow(Bucky::TestEquipment::PageObject::Pages).to receive(:new)
      allow(Bucky::TestEquipment::UserOperation::UserOperator).to receive(:new)
      subject.t_equip_setup
    end
    it 'call service_verifications.send' do
      expect(verification_double).to receive(:send)
      subject.verify(**verify_args)
    end
  end

  describe '#operate' do
    let(:user_operator_double) { double('user_operator double') }
    let(:op_args) { { exec: { operate: 'click', page: 'top', part: { locate: 'rosen_tokyo', num: 1 } }, step_number: 1, proc_name: 'test proc' } }
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
      subject.operate(**op_args)
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
