# frozen_string_literal: true

require_relative '../../../lib/bucky/core/test_core/test_case_loader'

describe Bucky::Core::TestCore::TestCaseLoader do
  describe '.load_testcode' do
    subject(:subject) { Bucky::Core::TestCore::TestCaseLoader.load_testcode(test_cond) }
    let(:bucky_home) { './spec/test_code' }

    before do
      $bucky_home_dir = bucky_home
    end

    context 'In case there are some arguments' do
      context 'when give args of test suite' do
        let(:test_cond) { { suite_name: [expect_scenario], test_category: 'e2e' } }
        let(:expect_scenario) { 'scenario_a' }
        it 'return test code object' do
          expect(subject).not_to be_empty
        end
        it 'return test code specified by test id' do
          subject.each do |code|
            expect(code[:test_suite_name]).to eq expect_scenario
          end
        end
      end

      context 'When give args of priority' do
        let(:test_cond) { { priority: [expect_priority], test_category: 'e2e' } }
        let(:expect_priority) { 'middle' }
        it 'return test code object' do
          expect(subject).not_to be_empty
        end
        it 'return test code specified by priority' do
          subject.each do |code|
            expect(code[:suite][:priority]).to eq expect_priority
          end
        end
      end
    end
  end
end
