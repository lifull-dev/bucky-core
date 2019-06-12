# frozen_string_literal: true

require_relative '../../../lib/bucky/core/test_core/test_manager'
require 'test/unit'
Test::Unit::AutoRunner.need_auto_run = false

describe Bucky::Core::TestCore::TestManager do
  # Class Double
  let(:tdo) { double('tdo-double') }
  before do
    allow(Bucky::Core::Database::TestDataOperator).to receive(:new).and_return(tdo)
    allow(tdo).to receive(:save_job_record_and_get_job_id)
    allow(tdo).to receive(:get_ng_test_cases_at_last_execution).and_return(ng_case_data)
    allow(tm).to receive(:do_test_suites)
  end

  describe '#run' do
    let(:tm) { Bucky::Core::TestCore::TestManager.new(re_test_count: re_test_count) }

    describe '@re_test_count: run untill max round' do
      context '@re_test_count is 1' do
        let(:re_test_count) { 1 }
        let(:ng_case_data) { { test_case: 1 } }
        it 'call load_test_suites once' do
          expect(tm).to receive(:load_test_suites).once
          tm.run
        end
      end

      context '@re_test_count is 2' do
        let(:re_test_count) { 2 }
        let(:ng_case_data) { { test_case: 1 } }
        it 'call load_test_suites twice' do
          expect(tm).to receive(:load_test_suites).twice
          tm.run
        end
      end
    end

    describe '@tdo.get_ng_test_cases_at_last_execution' do
      context 'there is no failure' do
        let(:re_test_count) { 2 }
        let(:ng_case_data) { {} }
        it 'call load_test_suites once' do
          expect(tm).to receive(:load_test_suites).once
          tm.run
        end
      end
    end
  end

  describe '#rerun' do
    let(:tm) { Bucky::Core::TestCore::TestManager.new(re_test_count: re_test_count, job: rerun_job_id) }
    before do
      allow(tdo).to receive(:get_last_round_from_job_id)
    end

    describe 'call execute_test on rerun method' do
      context 'there is no failure in round 2' do
        let(:re_test_count) { 2 }
        let(:rerun_job_id) { 10 }
        let(:ng_case_data) { {} }
        it 'call execute_test' do
          expect(tm).to receive(:execute_test)
          tm.rerun
        end
      end
    end
  end

  describe '#parallel_helper' do
    let(:tm) { Bucky::Core::TestCore::TestManager.new(re_test_count: 1) }
    before do
      $debug = true
    end
    after do
      $debug = false
    end
    context 'run test in multiprocess' do
      let(:ng_case_data) { {} }
      let(:parallel_num) { 2 }
      let(:test_suite_data) { [{:test_class_name=>"test", :test_suite_name=>"test", :test_category=>"e2e", :suite=>{:device=>"pc", :service=>"spec", :test_category=>"e2e", :cases=>[{:case_name=>"test_1"}]}}]}

      it 'create test class instance in fork' do
        allow(tm).to receive(:fork) do |&block|
          expect(block.call).to eq(Bucky::Core::TestCore::TestClasses::TestSpecPcE2etest)
        end
        tm.send(:parallel_helper, test_suite_data, parallel_num)
      end
    end
  end
end
