# frozen_string_literal: true

require_relative '../../../lib/bucky/core/exception/bucky_exception'

describe Bucky::Core::Exception do
  let(:error) { StandardError }
  let(:config_double) { double('double of Config') }
  before do
    allow(Bucky::Utils::Config).to receive(:instance).and_return(config_double)
    allow(config_double).to receive('[]').and_return(bucky_error: 'test')
  end

  describe Bucky::Core::Exception::BuckyException do
    let(:klass) { Bucky::Core::Exception::BuckyException }
    describe '.handle' do
      it 'call BuckyLogger.write' do
        expect(Bucky::Utils::BuckyLogger).to receive(:write)
        klass.handle(error)
      end
    end
  end

  describe Bucky::Core::Exception::DbConnectorException do
    let(:klass) { Bucky::Core::Exception::DbConnectorException }
    describe '.handle' do
      it 'raise error' do
        allow(Bucky::Core::Exception::BuckyException).to receive(:handle)
        expect { klass.handle(error) }.to raise_error(error)
      end
    end
  end

  describe Bucky::Core::Exception::WebdriverException do
    let(:klass) { Bucky::Core::Exception::WebdriverException }
    describe '.handle' do
      it 'raise error' do
        allow(Bucky::Core::Exception::BuckyException).to receive(:handle)
        expect { klass.handle(error) }.to raise_error(error)
      end
    end
  end
end
