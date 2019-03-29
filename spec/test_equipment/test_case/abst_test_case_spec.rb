# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/test_case/abst_test_case'

describe Bucky::TestEquipment::TestCase::AbstTestCase do
  Test::Unit::AutoRunner.need_auto_run = false

  let(:this_class) { Bucky::TestEquipment::TestCase::AbstTestCase }
  context 'not debug mode' do
    describe '.startup' do
      it 'call Bucky::Core::TestCore::TestResult.instance' do
        expect(Bucky::Core::TestCore::TestResult).to receive(:instance)
        this_class.startup
      end
    end
    describe '.shutdown' do
      let(:test_result_double) { double('test result double') }
      before do
        allow(Bucky::Core::TestCore::TestResult).to receive(:instance).and_return(test_result_double)
        this_class.startup
      end
      it 'call @@this_result.save' do
        expect(test_result_double).to receive(:save)
        this_class.shutdown
      end
    end
    describe '#teardown' do
      subject { this_class.new('test_method_name') }
      let(:added_result_info) { double('added_result_info_double') }
      let(:test_result_double) { double('this_result_double') }
      before do
        allow(Bucky::Core::TestCore::TestResult).to receive(:instance).and_return(test_result_double)
        allow(subject).to receive(:suite_id).and_return(1)
        allow(subject).to receive(:start_time).and_return(Time.now)
        this_class.startup
        this_class.class_variable_set('@@added_result_info', added_result_info)
      end
      it 'call @@added_result_info[]' do
        expect(added_result_info).to receive(:[]=)
        subject.teardown
      end
    end
  end
  context 'debug mode' do
    before do
      $debug = true
    end

    describe '.startup' do
      it 'not call Bucky::Core::TestCore::TestResult.instance' do
        expect(Bucky::Core::TestCore::TestResult).not_to receive(:instance)
        this_class.startup
      end
    end
    describe '.shutdown' do
      let(:test_result_double) { double('test result double') }
      before do
        allow(Bucky::Core::TestCore::TestResult).to receive(:instance).and_return(test_result_double)
        this_class.startup
      end
      it 'not call @@this_result.save' do
        expect(test_result_double).not_to receive(:save)
        this_class.shutdown
      end
    end
    describe '#teardown' do
      subject { this_class.new('test_method_name') }
      let(:elapsed_time_each_test_double) { double('elapsed_time_each_test_double') }
      before do
        this_class.startup
        allow(subject).to receive(:start_time).and_return(Time.now)
        this_class.class_variable_set('@@elapsed_time_each_test', elapsed_time_each_test_double)
      end
      it 'not call @@elapsed_time_each_test.push' do
        expect(elapsed_time_each_test_double).not_to receive(:push)
        subject.teardown
      end
    end
  end
end
