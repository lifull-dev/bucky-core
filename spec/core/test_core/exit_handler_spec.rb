# frozen_string_literal: true

require_relative '../../../lib/bucky/core/test_core/exit_handler'

describe Bucky::Core::TestCore::ExitHandler do
  let(:instance) { Bucky::Core::TestCore::ExitHandler.instance }

  describe '#initialize' do
    it 'initialize exit handler' do
      expect(instance.instance_variable_get(:@exit_code)).to eq 0
    end
  end

  describe '#reset' do
    it 'reset exit_code to 0' do
      instance.instance_variable_set(:@exit_code, 1)
      instance.reset
      expect(instance.instance_variable_get(:@exit_code)).to eq 0
    end
  end

  describe '#raise' do
    it 'raise exit code to 1' do
      instance.raise
      expect(instance.instance_variable_get(:@exit_code)).to eq 1
    end
  end

  describe '#bucky_exit' do
    it 'the exit value should be 1' do
      begin
        instance.instance_variable_set(:@exit_code, 1)
        instance.bucky_exit
      rescue SystemExit => e
        expect(e.status).to eq(1)
      end
    end

    it 'the exit value should be 0' do
      begin
        instance.instance_variable_set(:@exit_code, 0)
        instance.bucky_exit
      rescue SystemExit => e
        expect(e.status).to eq(0)
      end
    end
  end
end
