# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Layouts::GroupedTable, type: :model do
  describe 'Creation' do
    subject { described_class.new }

    it 'sets the name' do
      expect(subject.name).to eq('grouped_table')
    end

    it 'sets the headers' do
      expect(subject.headers).to eq([])
    end

    it 'sets the groups' do
      expect(subject.groups).to eq([])
    end
  end
end
