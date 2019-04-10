# frozen_string_literal: true

require_relative '../../lib/bucky/utils/yaml_load'

describe Bucky::Utils::YamlLoad do
  let(:yaml_load) { Class.new { extend Bucky::Utils::YamlLoad } }
  let(:yaml_file) { './spec/test_config/test_config.yml' }
  let(:yaml_dir) { './spec/test_config//**/*yml' }

  describe '#load_yaml' do
    it 'load target yaml' do
      expect(yaml_load.load_yaml(yaml_file)).to be_a(Hash)
    end
  end

  describe '#file_sort_hierarchy' do
    it 'sort and deepest file last' do
      expect(yaml_load.file_sort_hierarchy(yaml_dir).last).to include('hierarchy_config')
    end
  end
end
