# frozen_string_literal: true

require_relative '../../lib/bucky/utils/bucky_output'

describe Bucky::Utils::BuckyOutput do
  describe 'StringColorize' do
    using Bucky::Utils::BuckyOutput::StringColorize
    let(:string) { 'Hoge' }

    it '.black' do
      expect(string.black).to eql "\e[30m#{string}\e[0m"
    end

    it '.bg_green' do
      expect(string.bg_green).to eql "\e[42m#{string}\e[0m"
    end

    it '.bg_red' do
      expect(string.bg_red).to eql "\e[41m#{string}\e[0m"
    end
  end
end
