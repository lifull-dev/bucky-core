# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/user_operation/user_operator'

describe Bucky::TestEquipment::UserOperation::UserOperator do
  let(:pages_double) { double('pages double') }
  let(:user_operation_helper_double) { double('user_operation_helper double') }
  let(:uset_operator_args) { { service: 'sample_app', device: 'pc', driver: { driver: 'mock driver' }, pages: pages_double } }

  subject { Bucky::TestEquipment::UserOperation::UserOperator.new(uset_operator_args) }
  before do
    allow(Bucky::Utils::BuckyLogger).to receive(:write)
  end

  describe '#method_missing' do
    before do
      allow(Bucky::TestEquipment::UserOperation::UserOperationHelper).to receive(:new).and_return(user_operation_helper_double)
      allow(user_operation_helper_double).to receive_message_chain(:methods, :include?).and_return(operation_helper_methods?)
    end
    context 'when call method of operation helper' do
      let(:operation_helper_methods?) { true }
      let(:operation) { :go }
      let(:operation_args) { { exec: { operation: 'go' }, step_number: 1, proc_name: 'test proc' } }
      it 'call operation_helper.send' do
        expect(user_operation_helper_double).to receive(:send)
        subject.send(operation, 'test_method_name', **operation_args)
      end
    end
    context 'when call method of other than operation helper' do
      let(:page_double) { double('page double') }
      let(:part_double) { double('part double') }
      let(:operation_helper_methods?) { false }
      let(:operation) { :go }
      let(:operation_args) { { exec: { operation: 'go' }, step_number: 1, proc_name: 'test proc' } }

      it 'not call operation_helper.send' do
        expect(user_operation_helper_double).not_to receive(:send)
        subject.send(operation, 'test_method_name', **operation_args)
      end

      context 'when call method of pageobject' do
        let(:operation) { :input_inquire_info }
        let(:operation_args) { { exec: { page: 'top', operate: 'input_inquire_info' }, step_number: 1, proc_name: 'test proc' } }
        it 'call pageobject.send' do
          allow(pages_double).to receive(:send).and_return(page_double)
          expect(page_double).to receive(:send)
          subject.send(operation, 'test_method_name', **operation_args)
        end
      end
      context 'when call method of part' do
        let(:operation) { :click }
        context 'in case single part' do
          let(:operation_args) { { exec: { page: 'top', part: 'rosen_tokyo' }, step_number: 1, proc_name: 'test proc' } }
          it 'call send of part object' do
            allow(pages_double).to receive(:send).and_return(page_double)
            allow(page_double).to receive(:send).and_return(part_double)
            expect(part_double).to receive(:send).with(operation)
            subject.send(operation, 'test_method_name', **operation_args)
          end
        end
        context 'in case operate one part of multiple parts' do
          let(:operation_args) { { exec: { page: 'top', part: { locate: 'rosen_tokyo', num: 1 } }, step_number: 1, proc_name: 'test proc' } }
          let(:parts_double) { double('parts double') }
          it 'call send of part object' do
            allow(pages_double).to receive(:send).and_return(page_double)
            allow(page_double).to receive(:send).and_return(parts_double)
            allow(parts_double).to receive(:[]).and_return(part_double)
            expect(part_double).to receive(:send)
            subject.send(operation, 'test_method_name', **operation_args)
          end
        end
      end
    end
    context 'when raise exception' do
      let(:operation_helper_methods?) { true }
      let(:operation) { :go }
      let(:operation_args) { { exec: { operation: 'go' }, step_number: 1, proc_name: 'test proc' } }
      let(:exception) { StandardError }
      it 'call WebdrverException.handle' do
        allow(user_operation_helper_double).to receive(:send).and_raise(exception)
        expect { subject.send(operation, 'test_method_name', operation_args) }.to raise_error(exception)
      end
    end
  end
end
