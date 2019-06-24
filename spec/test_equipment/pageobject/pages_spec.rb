# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/pageobject/pages'

describe Bucky::TestEquipment::PageObject::Pages do
  let(:service) { 'service_a' }
  let(:device) { 'pc' }
  let(:driver) { 'driver' }
  let(:page_name) { :sample_page }
  let(:bucky_home) { './spec/test_code' }

  before { $bucky_home_dir = bucky_home }
  subject { Bucky::TestEquipment::PageObject::Pages.new(service, device, driver) }

  describe '#initialize' do
    it 'define instance method with pageobject name' do
      expect(subject).to respond_to page_name
    end
  end

  describe '#get_part' do
    let(:page_double) { double('page double') }
    let(:part_double) { double('part double') }
    context 'in case single part' do
      let(:operation_args) { { page: 'test_page', part: 'rosen_tokyo' } }
      it 'call send on partobject' do
        allow(subject).to receive(:send).and_return(page_double)
        allow(page_double).to receive(:send).and_return(part_double)
        expect(part_double).to receive(:first)
        subject.get_part(operation_args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:operation_args) { { page: 'top', part: { locate: 'rosen_tokyo', num: 1 } } }
      let(:parts_double) { double('parts double') }
      it 'call [] on partobject' do
        allow(subject).to receive(:send).and_return(parts_double)
        allow(parts_double).to receive(:send).and_return(part_double)
        expect(part_double).to receive(:[])
        subject.get_part(operation_args)
      end
    end
  end

  describe '#part_plural?' do
    let(:args) { { page: 'bukken_detail', part: { locate: 'buttons', num: 0 } } }
    it 'if part have "num", return true' do
      expect(subject.part_plural?(args)).to be true
    end
  end

  describe '#part_exist?' do
    let(:get_part_double) { double('get_part double') }
    let(:operation_args) { { page: 'test_page', part: 'rosen_tokyo' } }
    let(:error) { Selenium::WebDriver::Error::NoSuchElementError }
    context 'get part' do
      it 'if part exists, return true' do
        allow(subject).to receive(:get_part).and_return(get_part_double)
        expect(subject.part_exist?(operation_args)).to be true
      end
      it 'if raise NoSuchElementError, return false' do
        allow(subject).to receive(:get_part).and_raise(error)
        expect(subject.part_exist?(operation_args)).to be false
      end
    end
  end
end
