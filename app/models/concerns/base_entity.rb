# frozen_string_literal: true
# To be extended by models persisted in DB (Company, Account...)

# TODO: ActiveSupport::Concern
module BaseEntity
  extend ActiveSupport::Concern

  included do
    # To be overriden in entity
    def self.mapped_fields
      # :nocov:
      []
      # :nocov:
    end

    # To be overriden in entity
    def self.map(_channel_id, entity_hash)
      # :nocov:
      entity_hash
      # :nocov:
    end

    def self.authorised_attributes
      attribute_names
        .reject { |attribute| %w(created_at updated_at).include?(attribute) }
        .concat(mapped_fields)
    end

    def self.format_hash(entity_hash)
      entity_hash
        .with_indifferent_access
        .slice(*authorised_attributes)
        .deep_symbolize_keys
    end

    def self.upsert_all(channel_id, entities_array)
      valid_entities = entities_array.map do |entity_hash|
        next unless entity_hash.is_a?(Hash) && entity_hash.present?
        map(channel_id, format_hash(entity_hash))
      end.compact

      existing_entities = valid_entities.select { |entity_hash| exists?(entity_hash[:id]) }
      new_entities = valid_entities - existing_entities

      all_entities = create(new_entities) + existing_entities.map do |entity_hash|
        entity = find_by(id: entity_hash[:id])
        entity.update_attributes(entity_hash)
        entity
      end

      all_entities.map do |entity|
        next entity if entity.valid?

        Rails.logger.error "channel_id=#{channel_id}, action=upsert-all |" \
          " Cannot upsert #{entity.class} | #{entity.errors.full_messages}"
        nil
      end
    end
  end
end
