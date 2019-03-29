# frozen_string_literal: true

require_relative '../../../lib/bucky/core/database/db_connector'

describe Bucky::Core::Database::DbConnector do
  let(:config_double) { double('double of Config') }

  before do
    # Config mock
    allow(Bucky::Utils::Config).to receive(:instance).and_return(config_double)
    allow(config_double).to receive('[]').and_return(bucky_test: 'test')
  end

  describe '#connect' do
    it 'Call Sequel.connect' do
      allow(Sequel).to receive(:connect).and_return('call Sequel.connect')
      expect(Sequel).to receive(:connect)
      subject.connect('bucky_test')
    end
  end

  describe '#disconnect' do
    let(:sequel_double) { double('double of Sequel') }

    it 'Call Sequel.disconnect' do
      allow(Sequel).to receive(:connect).and_return(sequel_double)
      allow(sequel_double).to receive(:disconnect).and_return('call Sequel.disconnect')

      subject.connect

      expect(sequel_double).to receive(:disconnect)
      subject.disconnect
    end
  end
end
