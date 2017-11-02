# frozen_string_literal: true
# Receives notification containing data updates
class Api::V1::NotificationsController < ApplicationController
  # POST api/v1/notifications
  # {
  #   "channel_id": "org-abcd",
  #   "entities": {
  #     "journals": [{ "id": "156d15fa546df-dsfagfa-g4gf5sdf" }],
  #     "accounts": [{ "id": "254gf54sfgdgf-fss4254-ssdfdgf4" }]
  #   }
  # }
  # TODO: use ActionController::Metal to pass raw json request to ProcessNotificationWorker
  def create
    # channel_id = notification_params.require(:channel_id)

    notification_params.to_h[:entities].map do |entity_name, entities|
      # ExampleWorker.perform_later(channel_id, entity_name, entities)
    end
    head :ok
  end

  private

  # All entities types are authorised
  # TODO: better handling of arbitrary hashes in strong params:
  # -- https://github.com/rails/rails/commit/e86524c0c5a26ceec92895c830d1355ae47a7034
  def notification_params
    params.permit(:channel_id).tap do |whitelisted|
      whitelisted[:entities] = params[:entities]
    end.permit!
  end
end
