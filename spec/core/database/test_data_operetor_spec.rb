# frozen_string_literal: true

require_relative '../../../lib/bucky/core/database/test_data_operator'

describe Bucky::Core::Database::TestDataOperator do
  let(:test_data_operator) { Bucky::Core::Database::TestDataOperator.new }
  let(:sequel_instance_double) { double('double of Sequel') }
  let(:db_connector_double) { double('double of DbConnector') }
  let(:con_double) { double('double of con') }

  before do
    allow(Bucky::Core::Database::DbConnector).to receive(:new).and_return(db_connector_double)
    allow(db_connector_double).to receive(:connect)
    allow(db_connector_double).to receive(:disconnect)
  end

  describe '#initialize' do
    it 'call DbConnector#connect' do
      expect(db_connector_double).to receive(:connect)
      subject
    end
  end

  describe '#save_job_record_and_get_job_id' do
    let(:start_time) { Time.now }
    let(:command_and_option) { 'bucky run -t e2e' }
    before do
      allow(con_double).to receive(:[]).and_return(sequel_instance_double)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end
    it 'call Sequel#insert' do
      expect(sequel_instance_double).to receive(:insert)
      subject.save_job_record_and_get_job_id(start_time, command_and_option)
    end
    it 'return job_id' do
      allow(sequel_instance_double).to receive(:insert).and_return(1)
      expect(subject.save_job_record_and_get_job_id(start_time, command_and_option)).to eq 1
    end
    it 'disconnect database' do
      allow(sequel_instance_double).to receive(:insert)
      expect(db_connector_double).to receive(:disconnect)
      subject.save_job_record_and_get_job_id(start_time, command_and_option)
    end
  end

  describe '#save_test_result' do
    before do
      allow(con_double).to receive(:[]).and_return(sequel_instance_double)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end
    it 'call import' do
      expect(sequel_instance_double).to receive(:import)
      subject.save_test_result({})
    end
    it 'disconnect database' do
      allow(sequel_instance_double).to receive(:import)
      expect(db_connector_double).to receive(:disconnect)
      subject.save_test_result({})
    end
  end

  describe '#add_suite_id_to_loaded_suite_data' do
    let(:test_suite_data) do
      [
        {
          test_category: 'e2e',
          suite: { service: 'sample', device: 'pc' },
          test_suite_name: 'test_suite_a'
        }
      ]
    end
    before do
      allow(con_double).to receive(:[]).and_return(sequel_instance_double)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end
    it 'call con#filter,first' do
      expect(sequel_instance_double).to receive_message_chain(:filter, :first).and_return(test_suite_id: 1)
      subject.add_suite_id_to_loaded_suite_data(test_suite_data)
    end
  end

  describe '#update_test_suites_data' do
    let(:test_suite_data) do
      [
        {
          test_category: 'e2e',
          suite: {
            service: 'sample',
            device: 'pc',
            labels: 'test_label',
            cases: [
              { desc: 1,
                labels: 'test_label_1' },
              { desc: 2,
                labels: 'test_label_2' }
            ]
          },
          test_suite_name: 'test_suite_a'
        }
      ]
    end
    let(:sequel_test_suites) { double('double of Sequel_test_suites') }
    let(:sequel_test_cases) { double('double of Sequel_test_cases') }
    let(:sequel_where) { double('double of Sequel where response') }
    let(:sequel_labels) { double('double of Sequel_labels') }
    let(:sequel_test_case_labels) { double('double of Sequel_labels') }

    before do
      allow(Bucky::Utils::Config).to receive(:instance).and_return(test_code_repo: '/hoge/fuga')
      allow(con_double).to receive(:[]).with(:test_suites).and_return(sequel_test_suites)
      allow(con_double).to receive(:[]).with(:test_cases).and_return(sequel_test_cases)
      allow(con_double).to receive(:[]).with(:labels).and_return(sequel_labels)
      allow(con_double).to receive(:[]).with(:test_case_labels).and_return(sequel_test_case_labels)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end

    context 'In case test suites already saved' do
      before do
        allow(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_cases).to receive_message_chain(:filter, :first).and_return(nil)
        allow(sequel_test_cases).to receive(:insert)
        allow(sequel_test_suites).to receive(:where).and_return(sequel_where)
        allow(sequel_test_cases).to receive(:where).and_return(id: 1)
        allow(sequel_labels).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_case_labels).to receive(:insert)
      end
      it 'call update for test_suites' do
        expect(sequel_where).to receive(:update)
        subject.update_test_suites_data(test_suite_data)
      end
    end
    context 'In case test suites not saved' do
      before do
        allow(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(nil)
        allow(sequel_test_cases).to receive_message_chain(:filter, :first).and_return(nil)
        allow(sequel_test_cases).to receive(:insert)
        allow(sequel_labels).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_case_labels).to receive(:insert)
      end
      it 'call insert for test suites at once' do
        expect(sequel_test_suites).to receive(:insert).once
        subject.update_test_suites_data(test_suite_data)
      end
    end
    context 'In case all test cases already saved' do
      before do
        allow(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_suites).to receive(:where).and_return(sequel_where)
        allow(sequel_where).to receive(:update)
        allow(sequel_test_cases).to receive(:where).and_return(sequel_where)
        allow(sequel_test_cases).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_labels).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_case_labels).to receive_message_chain(:filter, :delete)
        allow(sequel_test_case_labels).to receive(:insert)
      end
      it 'call update for test_cases' do
        expect(sequel_where).to receive(:update)
        expect(sequel_where).to receive(:update)
        subject.update_test_suites_data(test_suite_data)
      end
    end
    context 'In case test cases not saved' do
      before do
        allow(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_suites).to receive(:where).and_return(sequel_where)
        allow(sequel_where).to receive(:update)
        allow(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_labels).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_case_labels).to receive(:insert)
      end
      it 'call insert for test cases at twice' do
        allow(sequel_test_cases).to receive_message_chain(:filter, :first).and_return(nil)
        expect(sequel_test_cases).to receive(:insert).twice
        subject.update_test_suites_data(test_suite_data)
      end
    end
    context 'In case some labels not saved' do
      before do
        allow(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_suites).to receive(:where).and_return(sequel_where)
        allow(sequel_where).to receive(:update)
        allow(sequel_test_cases).to receive(:where).and_return(sequel_where)
        allow(sequel_test_cases).to receive_message_chain(:filter, :first).and_return(id: 1)
        allow(sequel_test_case_labels).to receive_message_chain(:filter, :delete)
        allow(sequel_labels).to receive_message_chain(:filter, :first).and_return(nil)
        allow(sequel_test_case_labels).to receive(:insert)
      end
      it 'call insert for labels' do
        expect(sequel_labels).to receive(:insert).at_least(1).times
        subject.update_test_suites_data(test_suite_data)
      end
    end
  end

  describe '#get_ng_test_cases_at_last_execution' do
    let(:cond) { { is_error: 1, job_id: 1, round: 1 } }
    let(:sequel_test_results) { double('double of Sequel_test_results') }
    let(:sequel_test_cases) { double('double of Sequel_test_cases') }
    let(:suites_and_cases) do
      [
        {
          test_case_id: 1,
          case_name: 'top_page_1',
          case_description: 'top page',
          test_suite_id: 1,
          test_category: 'e2e',
          service: 'sample',
          device: 'pc',
          priority: 'high',
          test_suite_name: 'sample_top_page',
          suite_description: 'Toppage test',
          github_url: 'https://github.com/bucky/test-codes/blob/master/',
          revision: '/',
          file_path: 'services/sample/pc/scenarios/e2e/sample_top_page.rb'
        },
        {
          test_case_id: 2,
          case_name: 'detail_page_2',
          case_description: 'detail page',
          test_suite_id: 1,
          test_category: 'e2e',
          service: 'sample',
          device: 'pc',
          priority: 'high',
          test_suite_name: 'sample_top_page',
          suite_description: 'Toppage test',
          github_url: 'https://github.com/bucky/test-codes/blob/master/',
          revision: '/',
          file_path: 'services/sample/pc/scenarios/e2e/sample_top_page.rb'
        }
      ]
    end
    before do
      allow(db_connector_double).to receive(:con).and_return(con_double)
      allow(sequel_test_results).to receive_message_chain(:filter, :select, :all).and_return([{ test_case_id: 1 }])
      allow(con_double).to receive(:[]).with(:test_case_results).and_return(sequel_test_results)
      allow(sequel_test_cases).to receive_message_chain(:left_join, :where, :all).and_return(suites_and_cases)
      allow(con_double).to receive(:[]).with(:test_cases).and_return(sequel_test_cases)
    end
    it 'Check test_cond is in correct format' do
      expect_test_cond = {
        1 => { file_path: 'services/sample/pc/scenarios/e2e/sample_top_page.rb', case_names: %w[top_page_1 detail_page_2] }
      }
      expect(subject.get_ng_test_cases_at_last_execution(cond)).to eq expect_test_cond
    end
  end

  describe '#get_test_case_id' do
    let(:sequel_test_cases) { double('double of Sequel_test_cases') }
    before do
      allow(con_double).to receive(:[]).with(:test_cases).and_return(sequel_test_cases)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end
    it 'call filter,first' do
      expect(sequel_test_cases).to receive_message_chain(:filter, :first).and_return(test_case_id: 1)
      subject.get_test_case_id(1, 'case_description')
    end
  end

  describe '#get_last_round_from_job_id' do
    let(:sequel_test_cases) { double('double of Sequel_test_cases') }
    before do
      allow(con_double).to receive(:[]).with(:test_case_results).and_return(sequel_test_cases)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end
    it 'call where,max' do
      expect(sequel_test_cases).to receive_message_chain(:where, :max).and_return(round: 1)
      subject.get_last_round_from_job_id(1)
    end
  end

  describe '#get_test_suite_from_test_data' do
    let(:sequel_test_suites) { double('double of Sequel_test_suites') }
    let(:test_data) do
      {
        test_category: 'e2e',
        suite: {
          service: 'sample',
          device: 'pc'
        },
        test_suite_name: 'test_suite_a'
      }
    end
    before do
      allow(con_double).to receive(:[]).with(:test_suites).and_return(sequel_test_suites)
      allow(db_connector_double).to receive(:con).and_return(con_double)
    end
    it 'call filter,first' do
      expect(sequel_test_suites).to receive_message_chain(:filter, :first).and_return(id: 1)
      test_data_operator.send(:get_test_suite_from_test_data, test_data)
    end
  end
end
