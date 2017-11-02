# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Layouts::Base, type: :model do
  describe 'Creation' do
    subject { described_class.new }

    it 'sets the layout name based its class name' do
      expect(subject.name).to eq('base')
    end
  end

  describe '#render' do
    let(:layout) { described_class.new }

    subject { layout.render }

    it 'renders the layout in json, without the name' do
      layout.instance_variable_set(:@specific, 'content')
      is_expected.to eq({ specific: 'content' }.as_json)
    end
  end
end
