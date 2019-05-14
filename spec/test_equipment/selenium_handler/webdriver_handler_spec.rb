# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/selenium_handler/webdriver_handler'

describe Bucky::TestEquipment::SeleniumHandler::WebdriverHandler do
  include Bucky::TestEquipment::SeleniumHandler::WebdriverHandler
  let(:config_double) { double('double of Config') }
  let(:webdriver_double) { double('double of Webdriver') }
  let(:webdriver_manage_double) { double('double of Webdriver.manage') }
  let(:webdriver_manage_window_double) { double('double of Webdriver.manage.window') }
  let(:webdriver_manage_timeouts_double) { double('double of Webdriver.manage.timeouts') }
  let(:webdriver_manage_timeouts_double_implicit_wait) { double('double of Webdriver.manage.timeouts.implicit_wait') }

  before do
    allow(Bucky::Utils::Config).to receive(:instance).and_return(config_double)
    allow(config_double).to receive('[]').with(:browser).and_return(browser)
    allow(config_double).to receive('[]').with(:selenium_ip).and_return(selenium_ip)
    allow(config_double).to receive('[]').with(:selenium_port).and_return(selenium_port)
    allow(config_double).to receive('[]').with(:js_error_check).and_return(js_error_check)
    allow(config_double).to receive('[]').with(:js_error_collector_path).and_return(js_error_collector_path)
    allow(config_double).to receive('[]').with(:device_name_on_chrome).and_return(device_name_on_chrome)
    allow(config_double).to receive('[]').with(:sp_device_name).and_return(sp_device_name)
    allow(config_double).to receive('[]').with(:tablet_device_name).and_return(sp_device_name)
    allow(config_double).to receive('[]').with(:bucky_error).and_return(bucky_error)
    allow(config_double).to receive('[]').with(:driver_open_timeout).and_return(10)
    allow(config_double).to receive('[]').with(:driver_read_timeout).and_return(10)
    allow(config_double).to receive('[]').with(:user_agent).and_return(10)
    allow(config_double).to receive('[]').with(:find_element_timeout).and_return(10)
    allow(config_double).to receive('[]').with(:headless).and_return(headless)
    allow(Selenium::WebDriver).to receive(:for).and_return(webdriver_double)
    allow(webdriver_double).to receive(:manage).and_return(webdriver_manage_double)
    allow(webdriver_manage_double).to receive(:window).and_return(webdriver_manage_window_double)
    allow(webdriver_manage_window_double).to receive(:resize_to)
    allow(webdriver_manage_double).to receive(:timeouts).and_return(webdriver_manage_timeouts_double)
    allow(webdriver_manage_timeouts_double).to receive(:implicit_wait=)
  end

  describe '#create_webdriver' do
    let(:selenium_ip) { '11.22.33.44' }
    let(:selenium_port) { '4444' }
    let(:js_error_check) { true }
    let(:js_error_collector_path) { './' }
    let(:device_name_on_chrome) { { iphone6: 'Apple iPhone 6' } }
    let(:sp_device_name) { :iphone6 }
    let(:sp_device_name) { :ipad }
    let(:bucky_error) { 'bucky error' }
    let(:headless) { false }

    context 'pc' do
      let(:device_type) { 'pc' }
      context 'browser is chrome' do
        let(:browser) { :chrome }
        it 'call Selenium::WebDriver.for' do
          expect(Selenium::WebDriver).to receive(:for)
          create_webdriver(device_type)
        end
      end
      context 'browser is not chrome' do
        let(:browser) { :firefox }
        it 'raise exception' do
          expect(Bucky::Core::Exception::BuckyException).to receive(:handle)
          create_webdriver(device_type)
        end
      end
    end
    context 'sp' do
      let(:device_type) { 'sp' }
      context 'browser is chrome' do
        let(:browser) { :chrome }
        it 'call Selenium::WebDriver.for' do
          expect(Selenium::WebDriver).to receive(:for)
          create_webdriver(device_type)
        end
      end
      context 'browser is not chrome' do
        let(:browser) { :firefox }
        let(:selenium_mode) { :remote }
        it 'raise exception' do
          expect(Bucky::Core::Exception::BuckyException).to receive(:handle)
          create_webdriver(device_type)
        end
      end
    end
    context 'tablet' do
      let(:device_type) { 'tablet' }
      context 'browser is chrome' do
        let(:browser) { :chrome }
        it 'call Selenium::WebDriver.for' do
          expect(Selenium::WebDriver).to receive(:for)
          create_webdriver(device_type)
        end
      end
      context 'browser is not chrome' do
        let(:browser) { :firefox }
        let(:selenium_mode) { :remote }
        it 'raise exception' do
          expect(Bucky::Core::Exception::BuckyException).to receive(:handle)
          create_webdriver(device_type)
        end
      end
    end
  end
end
