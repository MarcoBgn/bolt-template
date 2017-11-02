# frozen_string_literal: true
# Base controller for all resources
class Api::V1::ResourcesController < ApplicationController
  include JSONAPI::ActsAsResourceController

  rescue_from ArgumentError do |e|
    render json: { errors: e.message }, status: :bad_request
  end
end
