# frozen_string_literal: true

require_relative '../../../lib/bucky/core/test_core/test_manager'

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
end
