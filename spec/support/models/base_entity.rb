# frozen_string_literal: true
require 'rails_helper'

# Allows to automate the testing of parents fetching mechanisms:
# When the mapped entity has a parent, base_entity will try to find it in the local database,
# if the parent is not found, it will be fetched from Connec!, persisted, and associated to the entity
PARENT_ENTITIES_SETTINGS = {
}.freeze

RSpec.shared_examples_for 'a BaseEntity model' do
  let(:formatted_hash) { described_class.format_hash(entities_array.first) }

  it { is_expected.to be_a(BaseEntity) }
  it { expect(described_class).to respond_to(:mapped_fields) }
  it { expect(described_class).to respond_to(:map) }

  describe '.authorised_attributes' do
    subject { described_class.authorised_attributes }

    described_class.mapped_fields.each do |field|
      it { is_expected.to include(field) }
    end

    it { is_expected.to_not include('created_at') }
    it { is_expected.to_not include('updated_at') }
  end

  describe '.upsert_all(channel_id, entities_array)' do
    subject { described_class.upsert_all(channel_id, entities_array) }

    it 'creates an entity per element in the array' do
      expect { subject }.to change { described_class.count }.by(entities_array.count)
      created_entities = described_class.last(entities_array.count)
      entities_array.each.with_index do |entity_hash, i|
        expect(created_entities[i].id).to eq(entity_hash['id'])
      end
    end

    it 'returns the created entities' do
      existing_entities = described_class.all.to_a
      is_expected.to eq(described_class.all.to_a - existing_entities)
    end

    context 'when the entity already exists' do
      it 'gets updated' do
        entities_array.map do |entity_hash|
          existing_entity = create(described_class.name.demodulize.underscore.to_sym, id: entity_hash['id'])
          # Factory returns different instance
          expect(described_class).to receive(:find_by).with(id: existing_entity.id).and_return(existing_entity)
          expect(existing_entity).to receive(:update_attributes).and_call_original
        end
        expect { subject }.to_not change { described_class.count }
      end
    end

    context 'when the entity creation failed' do
      before { allow_any_instance_of(described_class).to receive(:valid?).and_return(false) }

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).exactly(entities_array.count).times
        subject
      end

      it 'returns nil for the entity that failed to create' do
        is_expected.to eq(Array.new(entities_array.count, nil))
      end
    end
  end
end
