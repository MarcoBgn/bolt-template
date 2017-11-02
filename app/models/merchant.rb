# frozen_string_literal: true

# == Schema Information
#
# Table name: merchants
#
#  id         :string(36)       not null
#  name       :string(255)
#  street     :string(255)
#  city       :string(255)
#  state      :string(255)
#  postal     :string(255)
#  industry   :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Merchant < ApplicationRecord
  extend BaseEntity
  # == Validations ==========================================================
  validates :id, length: { is: 36 }
  # == Relationships ========================================================
  has_many :insights
end
