# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/selenium_handler/wait_handler'
require 'selenium-webdriver'
require 'English'

describe Bucky::TestEquipment::SeleniumHandler::WaitHandler do
  subject { Bucky::TestEquipment::SeleniumHandler::WaitHandler }
  describe '#wait_until_helper' do
    let(:timeout) { 0.5 }
    let(:interval) { 0.1 }
    let(:ignore) { StandardError }
    let(:test_block) { p 'test_block' }
    let(:test_block_raise_error) { raise StandardError }
    it 'not raise exeption' do
      expect { subject.wait_until_helper(timeout, interval, ignore) { test_block } }.not_to raise_error
    end

    it 'raise ignore exeption after timeout' do
      expect { subject.wait_until_helper(timeout, interval, ignore) { test_block_error } }.to raise_error(StandardError)
    end
  end
end
