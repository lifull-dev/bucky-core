# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/user_operation/user_operation_helper'
require 'selenium-webdriver'

describe Bucky::TestEquipment::UserOperation::UserOperationHelper do
  let(:driver_double) { double('driver double') }
  let(:pages_double) { double('pages double') }
  let(:user_operation_helpr_args) { { service: 'sample_app', device: 'pc', driver: driver_double, pages: pages_double } }

  subject { Bucky::TestEquipment::UserOperation::UserOperationHelper.new(user_operation_helpr_args) }

  describe '#go' do
    let(:operation) { :go }
    let(:args) { { url: 'http://example.com' } }
    it 'call driver.navigate' do
      expect(driver_double).to receive_message_chain(:navigate, :to)
      subject.send(operation, args)
    end
  end

  describe '#back' do
    let(:operation) { :back }
    it 'call driver.navigate.back' do
      expect(driver_double).to receive_message_chain(:navigate, :back)
      subject.send(operation, nil)
    end
  end

  describe '#refresh' do
    let(:operation) { :refresh }
    it 'call driver.navigate.refresh' do
      expect(driver_double).to receive_message_chain(:navigate, :refresh)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_next_window' do
    let(:operation) { :switch_to_next_window }
    let(:window_handles_double) { double('window_handles double') }
    let(:window_index) { 2 }
    let(:windows_number) { 4 }
    before do
      allow(driver_double).to receive(:window_handle)
      allow(driver_double).to receive_message_chain(:window_handles, :index).and_return(window_index)
      allow(driver_double).to receive_message_chain(:window_handles, :size).and_return(windows_number)
    end
    it 'call driver.switch_to.window' do
      allow(driver_double).to receive_message_chain(:window_handles, :[])
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, nil)
    end

    it 'switch to next window index' do
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive_message_chain(:window_handles, :[]).with(window_index + 1)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_previous_window' do
    let(:operation) { :switch_to_previous_window }
    let(:window_index) { 2 }
    before do
      allow(driver_double).to receive(:window_handle)
      allow(driver_double).to receive_message_chain(:window_handles, :index).and_return(window_index)
    end
    it 'call driver.switch_to.window' do
      allow(driver_double).to receive_message_chain(:window_handles, :[])
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, nil)
    end

    it 'switch to previous window index' do
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive_message_chain(:window_handles, :[]).with(window_index - 1)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_newest_window' do
    let(:operation) { :switch_to_newest_window }
    before do
      allow(driver_double).to receive_message_chain(:window_handles, :last)
    end
    it 'call driver.switch_to.window' do
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_oldest_window' do
    let(:operation) { :switch_to_oldest_window }
    before do
      allow(driver_double).to receive_message_chain(:window_handles, :first)
    end
    it 'call driver.switch_to.window' do
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, nil)
    end
  end

  describe '#switch_to_the_window' do
    let(:operation) { :switch_to_the_window }
    let(:args) { { window_name: 'new' } }
    let(:timeout_sec) { 2 }
    let(:args_with_timeout) { { window_name: 'new', timeout: timeout_sec } }
    it 'call driver.swich_to_window_by_name' do
      expect(driver_double).to receive_message_chain(:switch_to, :window)
      subject.send(operation, args)
    end
    it 'call wait_until_helper' do
      expect(subject).to receive(:wait_until_helper)
      subject.send(operation, args)
    end
    it 'call wait_until_helper with timeout argument' do
      expect(subject).to receive(:wait_until_helper) { |timeout, *| expect(timeout).to eq(timeout_sec) }
      subject.send(operation, args_with_timeout)
    end
  end

  describe '#close' do
    let(:operation) { :close }
    let(:window_index) { 2 }
    before do
      allow(driver_double).to receive(:window_handle)
      allow(driver_double).to receive_message_chain(:window_handles, :index).and_return(window_index)
    end
    it 'call driver.close' do
      allow(driver_double).to receive_message_chain(:window_handles, :[])
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive(:close)
      subject.send(operation, nil)
    end

    it 'switch to last window index' do
      allow(driver_double).to receive(:close)
      allow(driver_double).to receive_message_chain(:switch_to, :window)
      expect(driver_double).to receive_message_chain(:window_handles, :[]).with(window_index - 1)
      subject.send(operation, nil)
    end
  end

  describe '#stop' do
    let(:operation) { :stop }
    it 'call gets' do
      expect(subject).to receive(:gets)
      subject.send(operation, nil)
    end
  end

  describe '#input' do
    let(:operation) { :input }
    let(:args) { { page: 'top', part: 'form', word: 'hogehoge' } }
    let(:timeout_sec) { 2 }
    let(:args_with_timeout) { args.merge(timeout: timeout_sec) }
    let(:elem_double) { double('elem double') }
    it 'call part#send_keys' do
      expect(pages_double).to receive_message_chain(:get_part, :send_keys)
      subject.send(operation, args)
    end
    it 'call wait_until_helper' do
      allow(pages_double).to receive_message_chain(:get_part, :send_keys).and_return(elem_double)
      expect(subject).to receive(:wait_until_helper)
      subject.send(operation, args)
    end
    it 'call wait_until_helper with timeout argument' do
      allow(pages_double).to receive_message_chain(:get_part, :send_keys).and_return(elem_double)
      # Verify that some of the arguments match.
      expect(subject).to receive(:wait_until_helper) { |timeout, *| expect(timeout).to eq(timeout_sec) }
      subject.send(operation, args_with_timeout)
    end
  end

  describe '#clear' do
    let(:operation) { :clear }
    let(:args) { { page: 'top', part: 'form' } }
    it 'call part#clear' do
      expect(pages_double).to receive_message_chain(:get_part, :clear)
      subject.send(operation, args)
    end
  end

  describe '#click' do
    let(:operation) { :click }
    let(:args) { { page: 'top', part: 'form' } }
    let(:timeout_sec) { 2 }
    let(:args_with_timeout) { args.merge(timeout: timeout_sec) }
    let(:elem_double) { double('elem double') }
    it 'call part#click' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      expect(elem_double).to receive(:click)
      subject.send(operation, args)
    end
    it 'call part#location_once_scrolled_into_view' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(elem_double).to receive(:click)
      subject.send(operation, args)
    end
    it 'call wait_until_helper' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(elem_double).to receive(:click)
      expect(subject).to receive(:wait_until_helper)
      subject.send(operation, args)
    end

    it 'call wait_until_helper with timeout argument' do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(elem_double).to receive(:click)
      # Verify that some of the arguments match.
      expect(subject).to receive(:wait_until_helper) { |timeout, *| expect(timeout).to eq(timeout_sec) }
      subject.send(operation, args_with_timeout)
    end
  end

  describe '#choose' do
    let(:operation) { :choose }
    let(:args_text) { { page: 'top', part: 'form', text: 'foo' } }
    let(:args_value) { { page: 'top', part: 'form', value: 1 } }
    let(:args_index) { { page: 'top', part: 'form', index: 1 } }
    let(:args_error) { { page: 'top', part: 'form', error: 1 } }
    let(:timeout_sec) { 2 }
    let(:args_text_with_timeout) { args_text.merge(timeout: timeout_sec) }
    let(:option_double) { double('option double') }
    let(:elem_double) { double('elem double') }
    before do
      allow(pages_double).to receive(:get_part).and_return(elem_double)
      allow(Selenium::WebDriver::Support::Select).to receive(:new).with(elem_double).and_return(option_double)
    end
    it 'when there is text in keys, call driver.support.select.select_by with text' do
      expect(option_double).to receive(:select_by).with(:text, 'foo')
      subject.send(operation, args_text)
    end
    it 'when there is value in keys, call driver.support.select.select_by with value' do
      expect(option_double).to receive(:select_by).with(:value, '1')
      subject.send(operation, args_value)
    end
    it 'when there is index in keys, call driver.support.select.select_by with index' do
      expect(option_double).to receive(:select_by).with(:index, 1)
      subject.send(operation, args_index)
    end
    it 'if there is undefined key, raise exception' do
      expect { subject.send(operation, args_error) }.to raise_error(StandardError, 'Included invalid key [:page, :part, :error]')
    end
    it 'call wait_until_helper' do
      allow(option_double).to receive(:select_by).with(:text, 'foo')
      expect(subject).to receive(:wait_until_helper).and_return(option_double)
      subject.send(operation, args_text)
    end
    it 'call wait_until_helper with timeout argument' do
      allow(option_double).to receive(:select_by).with(:text, 'foo')
      # Verify that some of the arguments match.
      expect(subject).to receive(:wait_until_helper) { |timeout, *| expect(timeout).to eq(timeout_sec) }.and_return(option_double)
      subject.send(operation, args_text_with_timeout)
    end
  end

  describe '#accept_alert' do
    let(:operation) { :accept_alert }
    let(:alert_double) { double('alert double') }
    let(:timeout_sec) { 2 }
    let(:args_timeout) { { timeout: timeout_sec } }
    it 'call driver.switch_to.alert.accept' do
      expect(driver_double).to receive_message_chain(:switch_to, :alert, :accept)
      subject.send(operation, nil)
    end
    it 'call wait_until_helper' do
      allow(driver_double).to receive_message_chain(:switch_to, :alert).and_return(alert_double)
      allow(alert_double).to receive(:accept)
      expect(subject).to receive(:wait_until_helper).and_return(alert_double)
      subject.send(operation, nil)
    end
    it 'call wait_until_helper with timeout argument' do
      allow(driver_double).to receive_message_chain(:switch_to, :alert).and_return(alert_double)
      allow(alert_double).to receive(:accept)
      # Verify that some of the arguments match.
      expect(subject).to receive(:wait_until_helper) { |timeout, *| expect(timeout).to eq(2) }.and_return(alert_double)
      subject.send(operation, args_timeout)
    end
  end

  describe '#wait' do
    let(:operation) { :wait }
    let(:args) { { sec: 1 } }
    it 'call sleep' do
      expect(subject).to receive(:sleep)
      subject.send(operation, args)
    end
  end
end
