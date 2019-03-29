# frozen_string_literal: true

require_relative '../../../lib/bucky/test_equipment/evidence/evidence_generator'

describe Bucky::TestEquipment::Evidence::EvidenceGenerator do
  describe '#report' do
    it 'call BuckyLogger.write' do
      expect(Bucky::Utils::BuckyLogger).to receive(:write)
      subject.report('file_path', 'error_class')
    end
  end
end

describe Bucky::TestEquipment::Evidence::E2eEvidence do
  describe '#save_evidence' do
    it 'call #generate_screen_shot' do
      allow(subject).to receive(:report)
      expect(subject).to receive(:generate_screen_shot)
      subject.save_evidence('error_class')
    end
    it 'call #report' do
      allow(subject).to receive(:generate_screen_shot)
      expect(subject).to receive(:report)
      subject.save_evidence('error_class')
    end
  end
end
