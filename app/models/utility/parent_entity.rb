# frozen_string_literal: true
# Helper class that can be used to fetch parent entities from Connec! when they are not stored locally
class Utility::ParentEntity < ApplicationModel
  attr_accessor :int_klasses, :channel_id, :id, :ext_entity_name, :singular

  validates :channel_id, presence: true
  validate :can_identify?

  # Defines mapping between external and internal entities:
  # entity_type: {
  #   -- int_klasses can define a filter to be applied to the incoming hash
  #   -- to map the entity to the proper internal model
  #   -- If filter is nil, maps any incoming hash to the specified model
  #   int_klasses: {
  #     'INTERNAL_CLASS_NAME' => { filter to be applied on incoming hash },
  #     'OTHER_COMPATIBLE_CLASS' => { other filter }
  #   },
  #   ext_entity_name: 'entity name on external api (plural)',
  #   singular: true/false
  # }
  PARENT_TYPES = {
    # Example implementation Singleton
    example_singleton: {
      int_klasses: { 'Company' => nil },
      ext_entity_name: 'example',
      singular: true
    },
    # Example implementation Resources
    example: {
      int_klasses: { 'Example' => { type: 'CUSTOMER' }, 'Example2' => { type: 'SUPPLIER' } },
      ext_entity_name: 'examples',
      singular: false
    }
  }.with_indifferent_access.freeze

  def initialize(type, channel_id, id = nil)
    unless PARENT_TYPES[type].present?
      raise ArgumentError, "Parent type #{type} is not defined. Did you mean #{PARENT_TYPES.keys}?"
    end

    parent_type = PARENT_TYPES[type]

    self.int_klasses = parent_type[:int_klasses]
    self.channel_id = channel_id
    self.singular = parent_type[:singular]
    self.id = id unless singular
    self.ext_entity_name = parent_type[:ext_entity_name]
  end

  def fetch
    return nil unless valid?
    local_entity || remote_entity
  end

  private

    def can_identify?
      errors.add(:id, 'cannot be blank for non-singular entities') if !singular && id.blank?
    end

    def local_filter
      @local_filter ||= (singular ? { channel_id: channel_id } : { id: id })
    end

    # Attempt to fetch entity from local base
    def local_entity
      @local_entity ||= begin
        int_klasses.keys.find do |klass_name|
          entity = klass_name.constantize.find_by(local_filter)
          break entity if entity.present?
        end
      end
    end

    # Attempt to fetch entity from Connec!
    def remote_entity
      Clients::Connec.get_entity(channel_id, ext_entity_name, id) do |entity_hash|
        break nil unless entity_hash.present?

        int_klasses.any? do |klass_name, filter|
          if filter.blank? || filter.all? { |k, v| entity_hash.with_indifferent_access[k] == v }
            entity = klass_name.constantize.upsert_all(channel_id, [entity_hash])&.first
            break entity if entity.present?
          end
        end
      end
    end
end
