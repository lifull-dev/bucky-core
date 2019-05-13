# frozen_string_literal: true

require_relative '../../lib/bucky/tools/lint'

describe Bucky::Tools::Lint do
  let(:lint) { Bucky::Tools::Lint }
  let(:data_double) { { k1: 'v1', k2: { k3: 'v2' }, k4: { k5: { k6: 'v3', k7: 'v4' } } } }
  let(:rule_data_double) { { k1: 'v1', k2: { k3: 'v2' }, k4: { k5: { k6: 'v3', k8: 'v4' } } } }
  let(:config_dir) { "#{File.dirname(__FILE__)}/config_spec.yml" }
  let(:rule_config_dir) { "#{File.dirname(__FILE__)}/rule_config_spec.yml" }
  let(:dummy_dir) { '/hoge/*yml' }

  before do
    lint.class_variable_set(:@@config_dir, config_dir)
    lint.class_variable_set(:@@rule_config_dir, config_dir)
  end

  # [TODO] call method dynamically
  describe '#self.check' do
    it 'not raise exception, when argument is config' do
      lint.class_variable_set(:@@config_dir, config_dir)
      lint.class_variable_set(:@@rule_config_dir, config_dir)
      expect { lint.check('config') }.not_to raise_error
    end
    it 'raise exception, when call not exist method' do
      expect { lint.check('hoge') }.to raise_error(StandardError)
    end
  end

  describe '#check_config' do
    it 'print error message, when there is difference of hash' do
      lint.class_variable_set(:@@rule_config_dir, rule_config_dir)
      expect { lint.check_config }.to output("\e[31m[ERROR] The following configures are undefined. Use default value automatically.\n- device_name_on_chrome-ipad\e[0m\n{device_name_on_chrome-ipad: }\n").to_stdout
    end
    it 'print ok, when there is no difference of hash' do
      lint.class_variable_set(:@@dir, config_dir)
      lint.class_variable_set(:@@rule_config_dir, config_dir)
      expect { lint.check_config }.to output("\e[32mok\e[0m\n").to_stdout
    end
  end

  describe '#merge_yaml_data' do
    it 'load yaml and make hash' do
      expect(lint.send(:merge_yaml_data, config_dir)).to be_a(Hash)
    end
    it 'when there is no key in yaml, raise exception' do
      expect { lint.send(:merge_yaml_data, dummy_dir) }.to raise_error(StandardError, "No key! please check the directory existence [#{dummy_dir}]")
    end
  end

  describe '#make_message' do
    it 'when there are element in given array, print error message' do
      expect { lint.send(:make_message, ['foo']) }.to output("\e[31m[ERROR] The following configures are undefined. Use default value automatically.\n- foo\e[0m\n{foo: }\n").to_stdout
    end
    it 'when there are no element in given array, print ok' do
      expect { lint.send(:make_message, []) }.to output("\e[32mok\e[0m\n").to_stdout
    end
  end

  describe '#diff_arr' do
    it 'return diff array' do
      arr1 = ['k1', 'k2-k3', 'k4-k5-k6', 'k4-k5-k7']
      arr2 = ['k1', 'k2-k3']
      expect(lint.send(:diff_arr, arr1, arr2)).to eq ['k4-k5-k6', 'k4-k5-k7']
    end
  end

  describe '#make_key_chain' do
    it 'return array containing elements of chain case' do
      expected_list = ['k1', 'k2-k3', 'k4-k5-k6', 'k4-k5-k7']
      expect(lint.send(:make_key_chain, data_double)).to eq expected_list
    end
  end
end
