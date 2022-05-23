# frozen_string_literal: true

require_relative '../../../lib/bucky/core/test_core/test_class_generator'
require 'test/unit'
Test::Unit::AutoRunner.need_auto_run = false

describe Bucky::Core::TestCore::TestClassGenerator.new(test_cond: 'for_test') do
  describe '#generate_test_class' do
    before do
      allow(Bucky::Utils::Config).to receive(:instance).and_return(linkstatus_open_timeout: 60)
      allow(Bucky::Utils::Config).to receive(:instance).and_return(linkstatus_read_timeout: 60)
    end
    let(:linkstatus_url_log) { { url: { code: 200, count: 1 } } }
    let(:linkstatus_data) do
      {
        test_class_name: 'SearchflowAreaTop',
        test_suite_name: 'searchflow_area_top',
        test_category: 'linkstatus',
        suite: {
          desc: 'check link on top page',
          device: device,
          service: 'foo',
          priority: 'high',
          test_category: 'linkstatus',
          cases: [
            {
              desc: 'top page',
              urls: ['http://localhost/hoge']
            }
          ]
        },
        test_suite_id: 6
      }
    end
    let(:e2e_data) do
      {
        test_class_name: 'SearchflowAreaTop',
        test_suite_name: 'searchflow_area_top',
        test_category: 'e2e',
        suite: {
          desc: 'description',
          device: 'pc',
          service: 'foo',
          priority: :high,
          test_category: :e2e,
          cases: [
            {
              desc: 'case_description',
              procs: [
                {
                  proc: 'open toppage',
                  exec:
                  {
                    operate: :go,
                    url: 'http://localhost/'
                  }
                }
              ]
            }
          ]
        }
      }
    end

    describe 'generate class' do
      let(:device) { 'pc' }
      it 'generate test class according to test suite data' do
        subject.generate_test_class(data: linkstatus_data, linkstatus_url_log: linkstatus_url_log)
        expect(subject.instance_variable_get(:@test_classes).const_get(:TestFooPcLinkstatusSearchflowAreaTop).name).to eq('Bucky::Core::TestCore::TestClasses::TestFooPcLinkstatusSearchflowAreaTop')
      end
    end

    describe 'generate method' do
      let(:device) { 'sp' }
      context 'in case of linkstatus' do
        it 'generate test method according to test suite data' do
          subject.generate_test_class(data: linkstatus_data, linkstatus_url_log: linkstatus_url_log)
          expect(subject.instance_variable_get(:@test_classes).const_get(:TestFooSpLinkstatusSearchflowAreaTop).instance_methods).to include :test_foo_sp_linkstatus_searchflow_area_top_0
        end
      end

      context 'in case of e2e' do
        it 'generate test method according to test suite data' do
          subject.generate_test_class(data: e2e_data)
          expect(subject.instance_variable_get(:@test_classes).const_get(:TestFooPcE2eSearchflowAreaTop).instance_methods).to include :test_foo_pc_e2e_searchflow_area_top_0
        end
      end
    end
  end
end
