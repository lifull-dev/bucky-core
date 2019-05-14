# frozen_string_literal: true

require_relative '../../lib/bucky/utils/config'

describe Bucky::Utils::Config do
  let(:config) { Bucky::Utils::Config.instance }
  let(:ssh_ip) { '123.123.123.123' }

  before do
    Singleton.__init__(Bucky::Utils::Config)
    Bucky::Utils::Config.class_variable_set(:@@dir, "#{__dir__}/*yml")
    allow_any_instance_of(described_class).to receive(:`).and_return(ssh_ip)
  end

  describe '#initialize' do
    it 'no error, when load yaml' do
      expect { config }.not_to raise_error
    end
  end

  describe '#switch_specified_word' do
    context 'when selenium_ip is "docker_host_ip"' do
      it '@data[:selenium_ip] is host server ip' do
        expect(config[:selenium_ip]).to eq(ssh_ip)
      end
    end
  end

  describe '#[]' do
    it 'no error, get data from multiple layers' do
      expect { config[:test_db][:bucky_test] }.not_to raise_error
    end
    it 'raise exception, when there is no specified key' do
      not_found_key = :whoamai
      expect { config[not_found_key] }.to raise_error("Undefined Config : #{not_found_key}\nKey doesn't match in config file. Please check config file in config/*")
    end
  end
end
