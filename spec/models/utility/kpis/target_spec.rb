# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Utility::Kpis::Target, type: :model do
  let(:attrs) { { min: 15.0, max: 20.0, triggered_interval_index: 2, currency: 'GBP' } }
  let(:target) { described_class.new(attrs) }

  describe 'Creation' do
    subject { target }
    it 'sets the attributes' do
      expect(subject.min).to eq(15.0)
      expect(subject.max).to eq(20.0)
      expect(subject.triggered_interval_index).to eq(2)
      expect(subject.messages).to eq([])
      expect(subject.currency).to eq('GBP')
    end

    context 'when attrs are stringified' do
      let(:attrs) { { min: '15.0', max: '20.0' } }
      it 'sets the min/max attrs as Floats' do
        expect(subject.min).to be_a(Float)
        expect(subject.max).to be_a(Float)
      end
    end

    context 'when attrs are nil' do
      let(:attrs) { { min: nil, max: nil, currency: nil } }
      it 'sets the min/max to nil' do
        expect(subject.min).to be_nil
        expect(subject.max).to be_nil
        expect(subject.currency).to be_nil
      end
    end
  end

  describe '#triggered?' do
    subject { target.triggered? }
    it { is_expected.to eq(false) }

    context 'when some messages have been set on the target' do
      before { target.messages.push('Target has been net for KPI') }
      it { is_expected.to eq(true) }
    end
  end
end
