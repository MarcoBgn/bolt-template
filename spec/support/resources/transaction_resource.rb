# frozen_string_literal: true
require 'rails_helper'

def all_attributes(resource_klass)
  resource_klass._attributes.keys + resource_klass._relationships.keys
end

# Shared Example for Transaction resources (Invoice, Bill...)
RSpec.shared_examples_for 'a Transaction resource' do
  subject { described_class.new(trx, {}) }

  it { is_expected.to have_attribute :title }
  it { is_expected.to have_attribute :transaction_number }
  it { is_expected.to have_attribute :status }
  it { is_expected.to have_attribute :amount }
  it { is_expected.to have_attribute :balance }
  it { is_expected.to have_attribute :currency }
  it { is_expected.to have_attribute :currency_rate }
  it { is_expected.to have_attribute :transaction_date }
  it { is_expected.to have_attribute :due_date }
  it { is_expected.to have_attribute :created_at }
  it { is_expected.to have_attribute :updated_at }

  it { is_expected.to filter(:due_date) }
  it { is_expected.to filter(:channel_id) }
  it { is_expected.to filter(:status) }

  describe 'Constants' do
    it { expect(described_class::RO_FIELDS).to eq([:id, :created_at, :updated_at]) }
  end

  describe '.updatable_fields' do
    subject { described_class.updatable_fields({}).sort }

    let(:attributes) { (all_attributes(described_class) - described_class::RO_FIELDS).sort }

    it { is_expected.to eq(attributes) }
  end

  describe '.creatable_fields' do
    subject { described_class.creatable_fields({}).sort }

    let(:attributes) { (all_attributes(described_class) - described_class::RO_FIELDS).sort }

    it { is_expected.to eq(attributes) }
  end
end
