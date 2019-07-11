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
    let(:element) do
      class Element end
      return Element.new
    end
    let(:elem_objects) { [element, element.dup] }
    context 'If given method name is included in FINDERS' do
      %w[class class_name css id link link_text name partial_link_text tag_name xpath].each do |method|
        it "If #{method} is given, find_elements(:#{method}, value) is call" do
          expect(driver).to receive(:find_elements).with(method.to_sym, value).and_return(elem_objects)
          subject.send(:find_elem, method, value)
        end
      end
      context 'Redefine Array methods in WebElement' do
        let(:method) { :xpath }
        before do
          allow(driver).to receive(:find_elements).with(method, value).and_return(elem_objects)
        end
        %w[[] each length].each do |redefined_method|
          it "#{redefined_method} method is redefined in WebElement instance" do
            elem = subject.send(:find_elem, method, value)
            expect(elem).to respond_to(redefined_method.to_sym)
          end
        end
        context '[] method' do
          it '[] method is called in multipule WebElements object, if [] method called with integers.' do
            elem = subject.send(:find_elem, method, value)
            expect(elem_objects).to receive(:[])
            elem[1]
          end
          it 'Attribute method is called in a single WebElement, if [] method called with string.' do
            elem = subject.send(:find_elem, method, value)
            expect(element).to receive(:attribute)
            elem['attribute_name']
          end
          it 'Attribute method is called in a single WebElement, if [] method called with symbol.' do
            elem = subject.send(:find_elem, method, value)
            expect(element).to receive(:attribute)
            elem[:attribute_name]
          end
          it 'Raise invalid argument type error, if [] method called with anything other than integers, strings, or symbols.' do
            elem = subject.send(:find_elem, method, value)
            expect { elem[[]] }.to raise_error(StandardError)
          end
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
