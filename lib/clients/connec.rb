# frozen_string_literal: true
# Client that interacts with the Connec! component of the Maestrano Suite
# Connec! holds the unified data-model for any organization
module Clients::Connec
  BASE_URL = "#{ENV['CONNEC_PROTOCOL']}://#{ENV['CONNEC_HOST']}"
  BASE_PARAMS = {
    headers: { 'Accept' => 'application/json' },
    basic_auth: { username: ENV['ROOT_KEY'], password: ENV['ROOT_SECRET'] }
  }.freeze

  def self.get_entity(channel_id, entity_name, entity_id)
    return unless channel_id.present? && entity_name.present?

    url = "#{BASE_URL}/api/v2/#{channel_id}/#{entity_name}/#{entity_id}"

    resp = Retryable.retryable do |attempt|
      log(channel_id, "connec-get-#{entity_name}", url, attempt)
      HTTParty.get(url, BASE_PARAMS)
    end

    if resp&.success?
      yield(resp.parsed_response[entity_name])
    else
      Rails.logger.warn(
        "channel_id=#{channel_id}, action=connec-get-#{entity_name}, status=#{resp.code} | " \
        "Cannot fetch entity id=#{entity_id}"
      )
      return
    end
  end

  def self.log(channel_id, action, url, attempt)
    Rails.logger.info(
      "channel_id=#{channel_id}, " \
      "action=#{action}, " \
      "endpoint=#{url}, " \
      "attempt=#{attempt + 1}/3"
    )
  end
  private_class_method :log
end
