# frozen_string_literal: true

require_relative '../../../lib/bucky/core/report/screen_shot_generator'

describe Bucky::Core::Report::ScreenShotGenerator do
  let(:test_class) { Struct.new(:test_class) { include Bucky::Core::Report::ScreenShotGenerator } }
  let(:driver) { double('double of driver') }
  let(:config_double) { double('double of Config') }
  let(:error) { StandardError }
  subject { test_class.new }

  before do
    allow(config_double).to receive('[]').and_return('screen_shot_path')
    allow(Bucky::Utils::Config).to receive(:instance).and_return(config_double)
  end

  describe '.generate_screen_shot' do
    it 'call Selenium::WebDriver::DriverExtensions::TakesScreenshot#save_screenshot' do
      expect(driver).to receive(:save_screenshot)
      subject.generate_screen_shot(driver, 'test_case_name')
    end
    context 'get error when calling save_screenshot' do
      it 'call BuckyException.handle' do
        allow(driver).to receive(:save_screenshot).and_raise(error)
        expect(Bucky::Core::Exception::BuckyException).to receive(:handle)
        subject.generate_screen_shot(driver, 'test_case_name')
      end
    end
  end
end
