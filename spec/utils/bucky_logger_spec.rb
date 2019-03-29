# frozen_string_literal: true

require_relative '../../lib/bucky/utils/bucky_logger'
require 'test/unit'
Test::Unit::AutoRunner.need_auto_run = false

describe Bucky::Utils::BuckyLogger do
  describe '#write' do
    let(:klass) { Bucky::Utils::BuckyLogger }
    let(:file_name) { 'test' }
    let(:logger) { double('logger double') }
    subject { klass.write(file_name, content) }
    before do
      allow(Logger).to receive(:new).and_return(logger)
    end

    context 'when args is string object' do
      let(:content) { [:operation, 'go', :url, 'http://example.com/'].to_s }
      it 'call logger.info' do
        expect(logger).to receive(:info)
        allow(logger).to receive(:close)
        subject
      end
      it 'call logger.close' do
        allow(logger).to receive(:info)
        expect(logger).to receive(:close)
        subject
      end
    end
    context 'when args is error object' do
      let(:content) { Test::Unit::AssertionFailedError }
      it 'call logger.info' do
        expect(logger).to receive(:info)
        allow(logger).to receive(:close)
        subject
      end
      it 'call logger.close' do
        allow(logger).to receive(:info)
        expect(logger).to receive(:close)
        subject
      end
    end
  end
end
