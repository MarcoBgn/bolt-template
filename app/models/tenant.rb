# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id          :string(36)       not null
#  external_id :string(255)
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Tenant < ApplicationRecord
  extend BaseEntity
  # == Validations ==========================================================
  validates :id, length: { is: 36 }
end
