# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Utility::TimeSpan do
  describe '#time_span' do
    it { expect(described_class.new('2d').time_span).to eq(2.days) }
    it { expect(described_class.new('3w').time_span).to eq(3.weeks) }
    it { expect(described_class.new('4m').time_span).to eq(4.months) }
    it { expect(described_class.new('5y').time_span).to eq(5.years) }
    it { expect(described_class.new('-3y').time_span).to eq(-3.years) }
    it { expect(described_class.new('+3y').time_span).to eq(3.years) }
    it { expect(described_class.new('2q').time_span).to eq(6.months) }
    it { expect(described_class.new('-2q').time_span).to eq(-6.months) }
  end

  describe '#period' do
    it { expect(described_class.new('2d').period).to eq('day') }
    it { expect(described_class.new('3w').period).to eq('week') }
    it { expect(described_class.new('4m').period).to eq('month') }
    it { expect(described_class.new('5y').period).to eq('year') }
    it { expect(described_class.new('6q').period).to eq('quarter') }
  end
end
