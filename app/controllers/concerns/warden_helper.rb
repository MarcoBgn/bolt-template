# frozen_string_literal: true
# Delegates the authentication to Warden middleware
module WardenHelper
  extend ActiveSupport::Concern

  included do
    if Rails.env.test?
      # Mocks :warden
      include Warden::Test::Mock
    else
      # :nocov:
      def warden
        request.env['warden']
      end
      # :nocov:
    end

    prepend_before_action :authenticate!
    delegate :authenticate!, to: :warden
  end
end
