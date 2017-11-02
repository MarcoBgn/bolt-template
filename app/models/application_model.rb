# frozen_string_literal: true
# Base Model to be used for non-activerecord classes
class ApplicationModel
  include ActiveModel::Model
  include ActiveModel::Validations
end
