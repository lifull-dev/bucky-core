# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/pageobject/base_pageobject'
require 'selenium-webdriver'

describe Bucky::TestEquipment::PageObject::BasePageObject do
  subject { Bucky::TestEquipment::PageObject::BasePageObject.new('a', 'b', 'c', driver) }
  let(:driver) { double('driver double') }
  describe '#initialize' do
    it 'not raise exeption' do
      expect { subject }.not_to raise_error
    end
  end
  describe '#find_elem' do
    let(:value) { 'content-1' }
    context 'If given method name is included in FINDERS' do
      %w[class class_name css id link link_text name partial_link_text tag_name xpath].each do |method|
        it "If #{method} is given, find_elements(:#{method}, value) is call" do
          expect(driver).to receive(:find_elements).with(method.to_sym, value).and_return([Object.new])
          subject.send(:find_elem, method, value)
        end
      end
    end
    it 'If given method name is not included in FINDERS, raise error' do
      method = 'invalid method name'
      allow(Bucky::Core::Exception::BuckyException).to receive(:handle)
      expect { subject.send(:find_elem, method, value) }.to raise_error(StandardError, "Invalid finder. #{method}")
    end
  end
end
