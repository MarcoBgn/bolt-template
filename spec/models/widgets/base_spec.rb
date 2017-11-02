# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Widgets::Base, type: :model do
  let(:layouts) { nil }
  let(:metadata) { {} }
  let(:args) { { layouts: layouts, metadata: metadata } }
  let(:widget) { described_class.new(args) }

  before { stub_const("#{described_class}::SUPPORTED_LAYOUTS", %w(chart grouped_table)) }

  describe 'Creation' do
    subject { described_class.new(args) }

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:organization_ids) }
    end

    it 'instantiates a widget' do
      is_expected.to be_a(Widgets::Base)

      expect(subject.layouts.count).to eq(2)
      expect(subject.layouts).to include(instance_of(Layouts::Chart))
      expect(subject.layouts).to include(instance_of(Layouts::GroupedTable))
    end

    context 'when some layouts are specified' do
      let(:layouts) { %w(chart anything) }

      it 'sets only the supported layouts' do
        expect(subject.layouts.count).to eq(1)
        expect(subject.layouts).to include(instance_of(Layouts::Chart))
      end
    end
  end

  describe '#compute' do
    subject { described_class.new(args).compute }
    it { expect { subject }.to raise_error(NotImplementedError) }
  end

  describe '#hist_parameters' do
    subject { described_class.new(args).hist_parameters }

    it do
      is_expected.to have_attributes(
        from_date: Time.zone.today.beginning_of_year,
        to_date: Time.zone.today,
        period: 'DAILY'
      )
    end

    context 'with some hist_parameters defined in the metadata' do
      let(:hist_parameters) { { from: '2015-01-01' } }

      before { metadata[:hist_parameters] = hist_parameters }

      it 'returns the hist_parameters' do
        expect(subject.from).to eq('2015-01-01')
      end
    end
  end

  describe '#currency' do
    subject { described_class.new(args).currency }

    it { is_expected.to be_nil }

    context 'with a currency defined in the metadata' do
      let(:currency) { 'AUD' }

      before { metadata[:currency] = currency }

      it 'returns the currency' do
        is_expected.to eq(currency)
      end
    end
  end

  describe '#organization_ids' do
    subject { described_class.new(args).organization_ids }

    it { is_expected.to be_nil }

    context 'with organization_ids defined in the metadata' do
      let(:organization_ids) { %w(org-fbba org-fbbi) }

      before { metadata[:organization_ids] = organization_ids }

      it 'returns the organization_ids' do
        is_expected.to eq(organization_ids)
      end
    end
  end

  describe '#render' do
    let(:widget) { Widgets::MyWidget.new(args) }

    subject { widget.render }

    before do
      # Stub child widget class
      class Widgets::MyWidget < Widgets::Base
        def fill_chart(layout); end

        def fill_grouped_table(layout); end

        def valid?
          true
        end

        def compute
          self
        end
      end
    end

    it 'computes the widget' do
      expect(widget).to receive(:compute)
      subject
    end

    it 'fills the layouts by calling the fill_methods' do
      expect(widget).to receive(:fill_chart).with(instance_of(Layouts::Chart))
      expect(widget).to receive(:fill_grouped_table).with(instance_of(Layouts::GroupedTable))
      subject
    end

    it 'merges each rendered layout' do
      widget.layouts.each do |l|
        allow(l).to receive(:render).and_return("rendered #{l.name}")
      end
      is_expected.to eq(
        'chart' => 'rendered chart',
        'grouped_table' => 'rendered grouped_table'
      )
    end

    context 'when SUPPORTED_LAYOUTS is not defined in the child class' do
      before { hide_const("#{described_class}::SUPPORTED_LAYOUTS") }
      it { expect { subject }.to raise_error(NameError) }
    end

    context 'when the widget is invalid' do
      before { allow(widget).to receive(:valid?).and_return(false) }
      it { is_expected.to eq(false) }
    end
  end

  describe '#hist_parameters_valid?' do
    subject { widget.send(:hist_parameters_valid?) }

    it { is_expected.to eq(true) }

    context 'with invalid hist parameters' do
      before { metadata[:hist_parameters] = { from: '2015-03-02', to: '2015-03-01' } }

      it { is_expected.to eq(false) }

      it 'adds errors to the widget object' do
        subject
        expect(widget.errors.details).to eq(hist_parameters: [{ error: 'from date should not be bigger than to date' }])
      end
    end
  end

  describe '#round(array_f)' do
    subject { widget.send(:round, [12.1496844, 5798.1565476]) }
    it 'rounds the elements of the array to the 2nd decimal' do
      is_expected.to eq([12.15, 5798.16])
    end
  end

  describe '#convert(amount_f, from_currency, at_date)' do
    subject { widget.send(:convert, 100.0, 'EUR', '2015-02-15') }

    before do
      metadata[:currency] = 'AUD'
      allow(Money.default_bank).to receive(:get_rate).with(Chronic.parse('2015-02-15'), 'EUR', 'AUD').and_return(1.5)
    end

    it 'converts the amount using HistoricalCachingBank rates' do
      is_expected.to eq(150.0)
    end
  end
end
