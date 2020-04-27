# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/verifications/status_checker'

describe Bucky::TestEquipment::Verifications::StatusChecker do
  let(:test_class) { Struct.new(:test_class) { include Bucky::TestEquipment::Verifications::StatusChecker } }
  let(:response) { double('response') }
  let(:device) { 'sp' }
  let(:link_check_max_times) { 3 }
  let(:url_log) do
    {
      'http://200.test': {
        code: '200',
        entity: 'test_entity',
        error_message: nil,
        count: 1
      },
      'http://300.test': {
        code: '300',
        entity: nil,
        error_message: nil,
        count: 1
      },
      'http://400.test': {
        code: '400',
        entity: nil,
        error_message: 'Status Error',
        count: 1
      },
      'http://max.test': {
        code: '500',
        entity: nil,
        error_message: 'Status Error',
        count: 3
      }
    }
  end

  describe 'http_status_check for timeout' do
    subject { test_class.new }
    let(:args) { { url: 'https://example.com/', device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] } }
    before do
      allow(subject).to receive(:check_log_and_get_response).and_raise(Net::ReadTimeout)
    end
    context 'timeout when checking status' do
      let(:args) { { url: 'http://timeout.test'.to_sym, device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] } }
      it 'include error message in result' do
        expect(subject.http_status_check(args).keys).to include :error_message
      end
    end
  end

  describe 'http_status_check' do
    subject { test_class.new }
    let(:args) { { url: 'https://example.com/', device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] } }
    before do
      allow(subject).to receive(:get_response).and_return(response)
      allow(response).to receive(:code).and_return(code)
      allow(response).to receive(:entity).and_return('<html><head></head><body></body></html>')
      allow(Bucky::Utils::Config).to receive(:instance).and_return(linkstatus_open_timeout: 60)
      allow(Bucky::Utils::Config).to receive(:instance).and_return(linkstatus_read_timeout: 60)
    end
    context 'http status code 200' do
      let(:args) { { url: 'http://200.test'.to_sym, device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] } }
      let(:code) { '200' }
      it 'not include error message in result' do
        expect(subject.http_status_check(args).keys).not_to include :error_message
      end
    end
    context 'http status code 300' do
      let(:code) { '300' }
      let(:redirect_url_1) { 'https://www.hoge1.com' }
      let(:redirect_url_2) { 'https://www.hoge2.com' }
      let(:redirect_url_3) { 'https://www.hoge3.com' }
      let(:redirect_url_4) { 'https://www.hoge4.com' }
      let(:redirect_url_5) { 'https://www.hoge5.com' }
      let(:redirect_url_6) { 'https://www.hoge6.com' }
      it 'call get_response 6th' do
        allow(response).to receive(:[]).and_return(URI)
        allow(response).to receive(:[]).and_return(redirect_url_1, redirect_url_2, redirect_url_3, redirect_url_4, redirect_url_5, redirect_url_6)
        expect(subject).to receive(:get_response).and_return(response).exactly(6).times
        subject.http_status_check(args)
      end
    end
    context 'http status code 400' do
      let(:args) { { url: 'http://400.test'.to_sym, device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] } }
      let(:code) { '400' }
      let(:error_message) { 'Status Error' }
      it 'include error message in result' do
        expect(subject.http_status_check(args).keys).to include :error_message
      end
    end
    context 'http status code is invalid' do
      let(:code) { 'invalid' }
      let(:error_message) { 'Status Code Invalid Error' }
      it 'include error message in result' do
        expect(subject.http_status_check(args).keys).to include :error_message
      end
    end
    context 'over max count of link check' do
      let(:args) { { url: 'http://max.test'.to_sym, device: device, link_check_max_times: link_check_max_times, url_log: url_log, redirect_count: 0, redirect_url_list: [] } }
      let(:code) { '500' }
      let(:error_message) { 'Status Error' }
      it 'include error message in result' do
        expect(subject.http_status_check(args).keys).to include :error_message
      end
    end
  end
  describe 'link_status_check' do
    subject { test_class.new }
    let(:url) { 'https://example.com/' }
    let(:links) { ['https://example.com/hoge', 'https://example.com/fuga'] }
    let(:code) { '200' }
    let(:exclude_urls) { ['https://example.com', 'https://example.com/fuga/*'] }
    let(:args) { { url: url, device: device, exclude_urls: exclude_urls, link_check_max_times: link_check_max_times, url_log: url_log } }
    before do
      allow(subject).to receive(:get_response).and_return(response)
      allow(response).to receive(:code).and_return(code)
      allow(response).to receive(:entity)
      allow(subject).to receive(:make_target_links).and_return(links)
      allow(Bucky::Utils::Config).to receive(:instance).and_return(linkstatus_thread_num: 4)
    end
    context 'no error base url, link url' do
      it 'not raise exception' do
        expect { subject.link_status_check(args) }.not_to raise_error
      end
    end
  end
  describe 'make_target_links' do
    let(:args) { { base_url: 'https://example.com', base_fqdn: 'example.com', url_reg: %r{^(https?://([a-zA-Z0-9\-_.]+))}, only_same_fqdn: only_same_fqdn, entity: entity } }
    subject { test_class.new.make_target_links(args) }
    context 'only_same_fqdn is true' do
      let(:only_same_fqdn) { true }
      context 'there is javascript:void' do
        let(:entity) do
          '<a href="https://example.com">link</a>
          <a href="javascript:void(0)">link</a>
          <a href="JavaScript:void(0)">link</a>'
        end
        ['javascript:void(0)', 'JavaScript:void(0)'].each do |expression|
          it "exclude #{expression}" do
            expect(subject).not_to include(expression)
          end
        end
      end
      context 'there is tel:(number)' do
        let(:entity) do
          '<a href="https://example.com"></a>
          <a href="tel:03-2222-2222"></a>
          <a href="Tel:03-2222-2222"></a>'
        end
        ['tel:03-2222-2222', 'Tel:03-2222-2222'].each do |expression|
          it "exclude #{expression}" do
            expect(subject).not_to include(expression)
          end
        end
      end
      context 'there is mailto:' do
        let(:entity) do
          '<a href="https://example.com"></a>
          <a href="mailto:hoge@hoge.com"></a>
          <a href="Mailto:hoge@hoge.com"></a>'
        end
        ['mailto:hoge@hoge.com', 'Mailto:hoge@hoge.com'].each do |expression|
          it "exclude #{expression}" do
            expect(subject).not_to include(expression)
          end
        end
      end
      context 'relative path' do
        let(:entity) { '<a href="/hoge/fuga/"></a>' }
        it 'connect with base_url' do
          expect(subject[0]).to eq "#{args[:base_url]}/hoge/fuga/"
        end
      end
      context 'relative path start by #' do
        let(:entity) { '<a href="#hoge"></a>' }
        it 'connect with base_url' do
          expect(subject[0]).to eq "#{args[:base_url]}#hoge"
        end
      end
      context 'relative path start without /' do
        let(:entity) { '<a href="hoge/fuga/"></a>' }
        it 'connect with base_url' do
          expect(subject[0]).to eq "#{args[:base_url]}/hoge/fuga/"
        end
      end
      context 'When different from base URL' do
        let(:entity) { '<a href="https://not.same.fqdn.com"></a>' }
        it 'exclude the link' do
          expect(subject).to be_empty
        end
      end
    end
    # only_same_fqdn will only be ture.
    # TODO: Enable this test after only_same_fqdn can be handle
    # context 'only_same_fqdn is false' do
    #   let(:only_same_fqdn) { false }
    #   let(:entity) { '<a href="https://not.same.fqdn.com"></a>' }
    #   it 'not exclude the link' do
    #     expect(subject).not_to be_empty
    #   end
    # end
  end
end
