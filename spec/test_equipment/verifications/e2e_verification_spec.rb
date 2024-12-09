# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/verifications/e2e_verification'
require_relative '../../../lib/bucky/test_equipment/pageobject/pages'

describe Bucky::TestEquipment::Verifications::E2eVerification do
  Test::Unit::AutoRunner.need_auto_run = false
  let(:driver) { double('driver double') }
  let(:pages_double) { double('pages double') }
  let(:pages) { pages_double }
  let(:test_case_name) {}
  let(:page_double) { double('page double') }
  let(:parts_double) { double('parts double') }
  let(:part_double) { double('part double') }
  let(:web_elem) { double('web double') }

  subject { Bucky::TestEquipment::Verifications::E2eVerification.new(driver, pages, test_case_name) }

  before do
    allow(Bucky::Utils::BuckyLogger).to receive(:write)
    allow(pages_double).to receive(:send).and_return(page_double)
    allow(page_double).to receive(:send).and_return(part_double)
  end

  describe '#pages_getter' do
    let(:pages) { Bucky::TestEquipment::PageObject::Pages }
    subject { Bucky::TestEquipment::Verifications::E2eVerification.new(driver, pages, test_case_name) }
    it 'call pages' do
      expect(subject.pages_getter).to eq pages
    end
  end

  describe '#assert_title' do
    let(:actual_title) { 'title' }
    let(:args) { { verify: 'assert_title', page: :top, part: :rosen, expect: 'title' } }
    before do
      allow(driver).to receive(:title).and_return(actual_title)
    end
    it 'call verify_rescue' do
      expect(subject).to receive(:verify_rescue)
      subject.assert_title(**args)
    end
    it 'call assert_equal' do
      expect(subject).to receive(:assert_equal)
      subject.assert_title(**args)
    end
  end

  describe '#assert_text' do
    let(:actual_text) { 'text' }
    before do
      allow(web_elem).to receive(:text).and_return('text')
      allow(pages_double).to receive(:get_part).and_return(web_elem)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_text', page: :top, part: :rosen, expect: 'text' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_text(**args)
      end
      it 'call assert_equal' do
        expect(subject).to receive(:assert_equal)
        subject.assert_text(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_text', page: :top, part: { locate: :rosen, num: 1 }, expect: 'text' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_text(**args)
      end
      it 'call assert_true' do
        expect(subject).to receive(:assert_equal)
        subject.assert_text(**args)
      end
    end
  end
  describe '#assert_contained_text' do
    let(:actual_text) { 'testhogetext' }
    before do
      allow(web_elem).to receive(:text).and_return('text')
      allow(pages_double).to receive(:get_part).and_return(web_elem)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_contained_text', page: :top, part: :rosen, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_contained_text(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert)
        subject.assert_contained_text(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_contained_text', page: :top, part: { locate: :rosen, num: 1 }, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_contained_text(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert)
        subject.assert_contained_text(**args)
      end
    end
  end
  describe '#assert_contained_url' do
    let(:actual_url) { 'http://example.com' }
    let(:args) { { verify: 'assert_contained_url', expect: 'example.com' } }
    before do
      allow(driver).to receive(:current_url).and_return(actual_url)
    end
    it 'call verify_rescue' do
      expect(subject).to receive(:verify_rescue)
      subject.assert_contained_url(**args)
    end
    it 'call assert' do
      expect(subject).to receive(:assert)
      subject.assert_contained_url(**args)
    end
  end
  describe '#assert_contained_attribute' do
    let(:actual_value) { 'testfugatext' }
    before do
      allow(web_elem).to receive(:[]).and_return('attribute')
      allow(pages_double).to receive(:get_part).and_return(web_elem)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_contained_attribute', page: :top, part: :rosen, attribute: 'href', expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_contained_attribute(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert)
        subject.assert_contained_attribute(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_contained_attribute', page: :top, part: { locate: :rosen, num: 1 }, attribute: 'href', expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_contained_attribute(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert)
        subject.assert_contained_attribute(**args)
      end
    end
  end
  describe '#assert_is_number' do
    let(:actual_text) { '8888888' }
    let(:text_double) { double('text double') }
    before do
      allow(text_double).to receive_message_chain(:text, :sub).and_return(actual_text)
      allow(pages_double).to receive(:get_part).and_return(text_double)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_is_number', page: :top, part: :rosen, expect: '123' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_is_number(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert)
        subject.assert_is_number(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_is_number', page: :top, part: { locate: :rosen, num: 1 }, expect: '123' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_is_number(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert)
        subject.assert_is_number(**args)
      end
    end
  end
  describe '#assert_display' do
    let(:actual) { true }
    before do
      allow(part_double).to receive(:displayed?).and_return(actual)
      allow(driver).to receive(:current_url).and_return('http://target_site.com')
      allow(pages_double).to receive(:get_part).and_return(part_double)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_display', page: :top, part: :rosen, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_display(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert_true)
        subject.assert_display(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_display', page: :top, part: { locate: :rosen, num: 1 }, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_display(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert_true)
        subject.assert_display(**args)
      end
    end
  end
  describe '#assert_exist_part' do
    let(:actual) { true }
    before do
      allow(driver).to receive(:current_url).and_return('http://target_site.com')
      allow(pages_double).to receive(:part_exist?).and_return(actual)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_exist_part', page: :top, part: :rosen, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_exist_part(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert_true)
        subject.assert_exist_part(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_exist_part', page: :top, part: { locate: :rosen, num: 1 }, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_exist_part(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert_true)
        subject.assert_exist_part(**args)
      end
    end
  end

  describe '#assert_not_exist_part' do
    let(:actual) { false }
    before do
      allow(driver).to receive(:current_url).and_return('http://target_site.com')
      allow(pages_double).to receive(:part_exist?).and_return(actual)
    end
    context 'in case single part' do
      let(:args) { { verify: 'assert_not_exist_part', page: :top, part: :rosen, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_not_exist_part(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert_false)
        subject.assert_not_exist_part(**args)
      end
    end
    context 'in case operate one part of multiple parts' do
      let(:args) { { verify: 'assert_not_exist_part', page: :top, part: { locate: :rosen, num: 1 }, expect: 'hoge' } }
      it 'call verify_rescue' do
        expect(subject).to receive(:verify_rescue)
        subject.assert_not_exist_part(**args)
      end
      it 'call assert' do
        expect(subject).to receive(:assert_false)
        subject.assert_not_exist_part(**args)
      end
    end
  end
end
