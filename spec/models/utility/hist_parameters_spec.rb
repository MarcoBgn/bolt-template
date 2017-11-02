# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Utility::HistParameters, type: :model do
  let(:attrs) { { 'from' => '2015-01-02', 'to' => '2015-03-30', 'period' => 'MONTHLY' } }

  subject { described_class.new(attrs) }

  describe 'Creation' do
    it { is_expected.to be_valid }

    context 'with a from date greater than to date' do
      let(:attrs) { { 'from' => '2015-03-02', 'to' => '2015-03-01', 'period' => 'MONTHLY' } }
      it { is_expected.to_not be_valid }
    end

    context 'with a time range' do
      let(:attrs) do
        {
          'from' => '2015-01-02',
          'to' => '2015-03-30',
          'period' => 'MONTHLY',
          'time_range' => '-4w'
        }
      end

      it 'sets from date based on to date and the time range' do
        expect(subject.from).to eq((Date.parse('2015-03-30') - 4.weeks).to_s)
      end

      context 'when to date is not set' do
        let(:attrs) { { 'from' => '2015-01-02', 'period' => 'MONTHLY', 'time_range' => '-4w' } }

        it 'ignores the time range attribute' do
          expect(subject.from).to eq('2015-01-02')
          expect(subject.period).to eq('MONTHLY')
        end
      end
    end
  end

  describe '#to_h' do
    it { expect(subject.to_h).to eq(from: '2015-01-02', to: '2015-03-30', period: 'MONTHLY') }
  end

  describe '#empty?' do
    it { is_expected.not_to be_empty }
    it { expect(described_class.new).to be_empty }
  end

  describe '#full?' do
    it { is_expected.to be_full }
    it { expect(described_class.new(from: '2015-01-02')).not_to be_full }
  end

  describe '#map' do
    it 'yields each interval boundaries' do
      expect { |b| subject.map(&b) }.to yield_successive_args(
        [Time.zone.parse('2015-01-02'), Time.zone.parse('2015-01-31')],
        [Time.zone.parse('2015-02-01'), Time.zone.parse('2015-02-28')],
        [Time.zone.parse('2015-03-01'), Time.zone.parse('2015-03-30')]
      )
    end
  end

  describe '#from_date' do
    it { expect(subject.from_date).to eq(Time.zone.parse(subject.from)) }
  end

  describe '#to_date' do
    it { expect(subject.to_date).to eq(Time.zone.parse(subject.to)) }
  end

  describe '#interval_end_dates' do
    it do
      expect(subject.interval_end_dates).to eq(
        [
          Time.zone.parse('2015-01-31'),
          Time.zone.parse('2015-02-28'),
          Time.zone.parse('2015-03-30')
        ]
      )
    end
  end

  describe '#today_interval_index' do
    before { Timecop.freeze(Time.zone.parse('2015-02-15')) }
    after { Timecop.return }

    it 'returns the index of the interval enclosing today\'s date' do
      expect(subject.today_interval_index).to eq(1)
    end

    context 'when the time period is strictly in the past' do
      before { attrs[:to] = Time.zone.today - 1.day }
      it { expect(subject.today_interval_index).to be_nil }
    end

    context 'when the time period is strictly in the future' do
      before { attrs[:from] = Time.zone.today + 1.day }
      it { expect(subject.today_interval_index).to eq(0) }
    end

    context 'when the time period is infinite' do
      before { attrs.merge!(to: nil, from: nil) }
      it { expect(subject.today_interval_index).to eq(0) }
    end

    context 'when the time period has to_date in the future but no from_date boundary' do
      before { attrs[:to] = nil }
      it { expect(subject.today_interval_index).to eq(0) }
    end

    context 'when the time period has from_date in the past but no to_date boundary' do
      before { attrs[:from] = nil }
      it { expect(subject.today_interval_index).to eq(0) }
    end
  end
end
