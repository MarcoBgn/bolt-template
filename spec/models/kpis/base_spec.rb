# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Kpis::Base, type: :model do
  let(:valid_target1) { { min: 10, max: 40, currency: 'GBP' } }
  let(:valid_target2) { { min: 20, currency: 'AUD' } }
  let(:targets) do
    {
      valid_watchable: [valid_target1, valid_target2],
      invalid_watchable: [{ min: 200, max: 500 }]
    }
  end
  let(:alerts) do
    [{ id: 1, service: 'inapp', recipients: [{ id: 1 }] }]
  end
  let(:currency) { nil }
  let(:hist_parameters) { nil }
  let(:settings) { { currency: currency, hist_parameters: hist_parameters } }
  let(:args) { { settings: settings, targets: targets, alerts: alerts } }

  before do
    stub_const('Kpis::Base::WATCHABLES', [:valid_watchable])

    # Stub child kpi class
    class Kpis::MyKpi < Kpis::Base
      def assess_valid_watchable!(watchable); end

      def format_alert_for_valid_watchable!(alert, watchable); end
    end
  end

  describe 'Creation' do
    subject { described_class.new(args) }

    it 'instantiates a kpi' do
      is_expected.to be_a(Kpis::Base)
      expect(subject.settings).to eq(args[:settings])
    end

    it 'builds & sets the supported watchables targets' do
      expect(subject.watchables.length).to eq(1)
      expect(subject.watchables.first).to be_a(Utility::Kpis::Watchable)
      expect(subject.watchables.first.targets.length).to eq(2)
      expect(subject.watchables.first.targets.first).to be_a(Utility::Kpis::Target)
      expect(subject.watchables.first.targets.first.min).to eq(10)
      expect(subject.watchables.first.targets.first.max).to eq(40)
      expect(subject.watchables.first.targets.first.currency).to eq('GBP')
    end

    it 'builds & sets alerts' do
      expect(subject.alerts.length).to eq(1)
      expect(subject.alerts.first).to be_a(Utility::Kpis::Alert)
      expect(subject.alerts.first.title).to eq(subject.title)
    end

    context 'when no targets are given' do
      before { args.delete(:targets) }
      it { expect(subject.watchables).to eq([]) }
    end

    context 'when no alerts are given' do
      before { args.delete(:alerts) }
      it { expect(subject.alerts).to eq([]) }
    end
  end

  describe '#title' do
    subject { described_class.new(args).title }

    it { is_expected.to eq('Base') }

    context 'when a child class is instantiated' do
      class Kpis::MyKpi < Kpis::Base; end

      subject { Kpis::MyKpi.new(args).title }

      it { is_expected.to eq('My Kpi') }
    end
  end

  describe '#hist_parameters' do
    subject { described_class.new(args).hist_parameters }

    it { is_expected.to be_empty }

    context 'with hist params defined in the settings' do
      let(:hist_parameters) { { from: '2015-01-01', to: '2015-03-31' } }

      it 'returns an HistParameters object' do
        is_expected.to be_a(Utility::HistParameters)
        expect(subject.to_h).to eq(hist_parameters)
      end
    end
  end

  describe '#currency' do
    subject { described_class.new(args).currency }

    it { is_expected.to be_nil }

    context 'with a currency defined in the settings' do
      let(:currency) { 'AUD' }

      it 'returns the currency' do
        is_expected.to eq(currency)
      end
    end
  end

  describe '#compute' do
    let(:kpi) { Kpis::MyKpi.new(args) }

    subject { kpi.compute }

    before do
      allow(kpi).to receive(:convert).and_return(10.55835435435)
    end

    it 'converts all target values for each watchable' do
      expect(kpi).to receive(:convert).with(kind_of(Float), valid_target1[:currency]).twice
      expect(kpi).to receive(:convert).with(kind_of(Float), valid_target2[:currency]).once
      subject
      expect(kpi.watchables.first.targets.first.min).to eq(10.56)
      expect(kpi.watchables.first.targets.first.max).to eq(10.56)
      expect(kpi.watchables.first.targets.last.min).to eq(10.56)
    end

    context 'if no currency is set on the target' do
      let(:valid_target1) { { min: 30 } }
      let(:valid_target2) { { max: 40 } }

      it 'does not convert the targets' do
        expect(kpi).to_not receive(:convert)
        subject
      end
    end

    it 'invokes the kpis assessment methods defined for each valid watchable' do
      kpi.watchables.each do |watchable|
        expect(kpi).to receive("assess_#{watchable.title}!").with(watchable)
      end
      subject
    end

    it 'returns self' do
      is_expected.to eq(kpi)
    end

    context 'when the kpi is not valid' do
      before { allow(kpi).to receive(:valid?).and_return(false) }

      it 'does not invoke the assessment methods' do
        kpi.watchables.each do |watchable|
          expect(kpi).to_not receive("assess_#{watchable.title}!")
        end
        subject
      end

      it 'returns self' do
        is_expected.to eq(kpi)
      end
    end
  end

  describe '#render' do
    let(:kpi) { described_class.new(args) }

    before do
      allow(kpi).to receive(:compute).and_return(kpi)
      allow(kpi).to receive(:triggered?).and_return(true)
    end

    it 'renders the expected results' do
      expected_result = { triggered: true, watchables: kpi.watchables.as_json }
      expect(kpi.render).to eq(expected_result)
    end
  end

  describe '#triggered?' do
    let(:kpi) { described_class.new(args) }
    let(:triggered) { true }
    let(:watchable) { double(Utility::Kpis::Watchable, title: 'valid_watchable', triggered?: triggered) }
    subject { kpi.triggered? }

    before { kpi.watchables = [watchable] }

    context 'when the watchable is triggered' do
      it { expect(subject).to eq(true) }
    end

    context 'when the watchable is not triggered' do
      let(:triggered) { false }
      it { expect(subject).to eq(false) }
    end

    context 'when there are no watchables' do
      before { kpi.watchables = [] }
      it { expect(subject).to eq(false) }
    end
  end

  describe '#dispatch_alerts' do
    let(:kpi) { Kpis::MyKpi.new(args) }
    let(:triggered) { true }
    let(:sent) { false }
    let(:watchable) { double(Utility::Kpis::Watchable, title: 'valid_watchable', triggered?: triggered, targets: []) }
    let(:alert) { double(service: 'inapp', sent: sent, dispatch: true) }

    subject { kpi.dispatch_alerts }

    before do
      kpi.watchables = [watchable]
      kpi.alerts = [alert]
    end

    RSpec.shared_examples 'a formatted by watchable and dispatched alert' do
      it 'is successful' do
        expect(kpi).to receive("format_alert_for_#{watchable.title}!").with(alert, watchable)
        expect(alert).to receive(:dispatch)
        subject
      end
    end

    it 'computes the kpi' do
      expect(kpi).to receive(:compute)
      subject
    end

    context 'alert not sent and watchable triggered' do
      it_behaves_like 'a formatted by watchable and dispatched alert'
    end

    context 'alert sent and watchable not triggered' do
      let(:triggered) { false }
      let(:sent) { true }
      it_behaves_like 'a formatted by watchable and dispatched alert'
    end

    context 'alert sent AND watchable triggered (something has gone wrong)' do
      let(:sent) { true }
      it 'is not formatted and dispatched' do
        expect(kpi).to_not receive("format_alert_for_#{watchable.title}!")
        expect(alert).to_not receive(:dispatch)
        subject
      end
    end
  end

  describe '.can_watch?(watchable)' do
    let(:watchable) { :valid_watchable }
    subject { described_class.can_watch?(watchable) }

    it { is_expected.to eq(true) }

    context 'when watchable is a string' do
      let(:watchable) { 'valid_watchable' }

      it { is_expected.to eq(true) }
    end

    context 'with an invalid watchable' do
      let(:watchable) { :invalid_watchable }

      it { is_expected.to eq(false) }
    end
  end

  describe '#convert(amount_f, from_currency, at_date)' do
    let(:currency) { 'AUD' }
    let(:kpi) { Kpis::MyKpi.new(args) }

    subject { kpi.send(:convert, 100.0, 'EUR', '2015-02-15') }

    before do
      allow(Money.default_bank).to receive(:get_rate).with(Chronic.parse('2015-02-15'), 'EUR', 'AUD').and_return(1.5)
    end

    it 'converts the amount using HistoricalCachingBank rates' do
      is_expected.to eq(150.0)
    end
  end
end
