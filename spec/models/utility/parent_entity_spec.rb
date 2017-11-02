# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Utility::ParentEntity, type: :model do
  let(:type) { :example }
  let(:channel_id) { 'org-fbba' }
  let(:id) { '16' }
  let(:parent) { described_class.new(type, channel_id, id) }

  subject { parent }

  it 'sets the attributes' do
    expect(subject.int_klasses).to eq('Example' => { 'type' => 'CUSTOMER' }, 'Example2' => { 'type' => 'SUPPLIER' })
    expect(subject.singular).to eq(false)
    expect(subject.id).to eq(id)
    expect(subject.ext_entity_name).to eq('examples')
  end

  context 'when the parent type is not defined' do
    let(:type) { :test }
    it { expect { subject }.to raise_error(ArgumentError) }
  end

  context 'when the parent type is singular' do
    let(:type) { :example_singleton }
    it 'does not set the parent entity id' do
      expect(subject.id).to be_nil
    end
  end

  describe 'Validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:channel_id) }

    context 'when the parent type is not singular and the id is not defined' do
      let(:id) { nil }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#fetch' do
    subject { parent.fetch }

    context 'when invalid' do
      before { allow(parent).to receive(:valid?).and_return(false) }
      it { is_expected.to be_nil }
    end

    context 'when the parent entity already exists' do
      # let!(:example) { create(:example, id: '16') }
      #
      # it 'does not fetch it from Connec!' do
      #   expect(Clients::Connec).not_to receive(:get_entity)
      #   subject
      # end
      #
      # it 'returns the entity' do
      #   is_expected.to eq(example)
      # end
    end

    context 'when the parent entity does not exist locally' do
      let(:entity_hash) { { 'id' => '16', 'type' => 'SUPPLIER' } }

      # TODO: to be changed to yield the entity_hash variable
      # allow(Clients::Connec).to receive(:get_entity).and_yield(entity_hash)
      before do
        # :nodoc:
        class Example
          include BaseEntity

          def self.find_by(*)
            # Stubbed method
          end
        end
        # :nodoc:
        class Example2
          include BaseEntity

          def self.find_by(*)
            # Stubbed method
          end
        end
      end

      it 'fetches it from Connec!' do
        allow(Example).to receive(:find_by)
        expect(Clients::Connec).to receive(:get_entity).with(channel_id, 'examples', '16')
        subject
      end

      context 'when no valid entity hash is returned from Connec!' do
        let(:entity_hash) { {} }

        before do
          stub_request(:get, 'https://changeme/api/v2/org-fbba/examples/16')
            .with(headers: { 'Accept' => 'application/json', 'Authorization' => 'Basic Y2hhbmdlbWU6Y2hhbmdlbWU=' })
            .to_return(status: 404, body: '', headers: {})
        end

        it { is_expected.to be_nil }

        it 'does not persist anything' do
          expect(Example).to_not receive(:upsert_all)
          expect(Example2).to_not receive(:upsert_all)
        end
      end

      context 'with a filter defined on the parent klass' do
        before do
          # allow(Example).to receive(:upsert_all)
          #   .with(channel_id, [entity_hash])
          #   .and_return(['persisted entity'])
        end

        it 'persists it using the parent klass that matches the filter' do
          # expect(Example2).to_not receive(:upsert_all)
          # expect(Example).to receive(:upsert_all).with(channel_id, [entity_hash])
          # subject
        end

        it 'returns the persisted entity' do
          # is_expected.to eq('persisted entity')
        end
      end

      context 'without filter on the parent klass' do
        let(:type) { :example }

        before do
          # allow(Example).to receive(:upsert_all)
          #   .with(channel_id, [entity_hash])
          #   .and_return(['persisted entity'])
        end

        it 'persists it using the parent klass' do
          # expect(Example).to receive(:upsert_all).with(channel_id, [entity_hash])
          # subject
        end

        it 'returns the persisted entity' do
          # is_expected.to eq('persisted entity')
        end
      end
    end
  end
end
