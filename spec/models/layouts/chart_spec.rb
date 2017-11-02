# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Layouts::Chart, type: :model do
  describe 'Creation' do
    subject { described_class.new }

    it 'sets the name' do
      expect(subject.name).to eq('chart')
    end

    it 'sets the series' do
      expect(subject.series).to eq([])
    end
  end

  describe '#add_series(series_hash)' do
    subject { described_class.new }

    it 'adds a series to the layout' do
      subject.add_series(a: 'series')
      expect(subject.series).to eq([{ a: 'series' }])
    end
  end
end
