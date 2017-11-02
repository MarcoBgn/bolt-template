# frozen_string_literal: true
# Client for the Pusher Websockets Rails server API.
# --------------------------------------------------------------
module Clients::PusherWebsockets
  def self.publish_event(channel, event, data)
    pusher_client.trigger(channel, event, data: data)
    Rails.logger.info "channel=#{channel}, action=pusher-publish-event, event=#{event}, data=#{data}"

  rescue Pusher::Error => e
    Rails.logger.error(
      "channel=#{channel}, " \
      'action=pusher-publish-event, ' \
      "event=#{event}, " \
      "data=#{data}, " \
      "message=#{e.message}"
    )
  end

  def self.pusher_client
    client = Pusher::Client.new(
      app_id: ENV['PUSHER_APP_ID'],
      key: ENV['PUSHER_KEY'],
      secret: ENV['PUSHER_SECRET']
    )

    # Call Pusher with SSL when not in dev
    client.encrypted = !Rails.env.development?
    client
  end
  private_class_method :pusher_client
end
