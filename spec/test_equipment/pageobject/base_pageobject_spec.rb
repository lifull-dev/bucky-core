# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/pageobject/base_pageobject'

describe Bucky::TestEquipment::PageObject::BasePageObject do
  subject { Bucky::TestEquipment::PageObject::BasePageObject.new('a', 'b', 'c', 'd') }
  describe '#initialize' do
    it 'not raise exeption' do
      expect { subject }.not_to raise_error
    end
  end
end
