# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/verifications/service_verifications'

describe Bucky::TestEquipment::Verifications::ServiceVerifications do
  let(:pages) { double('page') }
  let(:e2e_verification) { double('e2e_verification') }
  let(:assert_title_mock) { double('assert_title_mock') }
  let(:page_name) { :sample_page }
  let(:args) { { service: 'service_a', device: 'pc', driver: 'driver', method_name: 'test_case_name', pages: pages } }
  let(:bucky_home) { './spec/test_code' }

  subject { Bucky::TestEquipment::Verifications::ServiceVerifications.new(args) }
  before do
    $bucky_home_dir = bucky_home
    allow(pages).to receive(:send).and_return(page_name)
  end

  describe '#initialize' do
    it 'define all instance valiables' do
      expect(subject.instance_variable_get(:@service)).to eq 'service_a'
      expect(subject.instance_variable_get(:@device)).to eq 'pc'
      expect(subject.instance_variable_get(:@driver)).to eq 'driver'
      expect(subject.instance_variable_get(:@test_case_name)).to eq 'test_case_name'
      expect(subject.instance_variable_get(:@pages)).to eq pages
    end
  end

  describe '#method_missing' do
    let(:verify_args) { { exec: { verify: 'assert_title', expect: 'page title' }, step_number: 1, proc_name: 'test proc' } }
    let(:verify_page_args) { { exec: { page: page_name, verify: 'assert_sample', expect: 'page title' }, step_number: 1, proc_name: 'test proc' } }
    let(:dummy_verify_args) { { exec: { verify: 'hoge', expect: 'hoge' }, step_number: 1, proc_name: 'test proc' } }
    let(:page_method_double) { double('page method') }
    before do
      allow(Bucky::TestEquipment::Verifications::E2eVerification).to receive(:new).and_return(e2e_verification)
    end
    it 'if common e2e method, call send to e2e_verification' do
      allow(e2e_verification).to receive(:respond_to?).and_return(true)
      expect(e2e_verification).to receive(:send)
      subject.send('assert_title', **verify_args)
    end
    it 'if page verify method, call method of page instance' do
      allow(e2e_verification).to receive(:respond_to?).and_return(false)
      allow(args).to receive(:key?).and_return(true)
      allow(subject).to receive(page_name).and_return(page_method_double)
      expect(page_method_double).to receive(:assert_sample)
      subject.send('assert_sample', **verify_page_args)
    end
    let(:args_mock) { double('args_mock') }
    it 'if call undefined method, raise exception' do
      allow(e2e_verification).to receive(:respond_to?).and_return(false)
      allow(args).to receive(:key?).and_return(false)
      expect { subject.send('undefined method', dummy_verify_args) }.to raise_error(StandardError)
    end
  end
end
