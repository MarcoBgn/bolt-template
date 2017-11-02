# frozen_string_literal: true
# Client that interacts with the MnoHub component of the Maestrano Suite
# MnoHub holds the dashboards, widgets, kpis, etc. saved for a user or organization
module Clients::MnoHub
  BASE_URL = "#{ENV['MNOHUB_PROTOCOL']}://#{ENV['MNOHUB_HOST']}"
  BASE_PARAMS = {
    headers: { 'Accept' => 'application/json' },
    basic_auth: { username: ENV['ROOT_KEY'], password: ENV['ROOT_SECRET'] }
  }.freeze

  def self.get_kpis(org_uid)
    return unless org_uid.present?

    kpis_path = ENV['MNOHUB_PATHS_KPIS'].gsub(':organization_id', org_uid)
    url = File.join(BASE_URL, kpis_path)

    Retryable.retryable do |attempt|
      Rails.logger.info(
        "channel_id=#{org_uid}, " \
        'action=mnohub-get-kpis, ' \
        "endpoint=#{url}, " \
        "attempt=#{attempt + 1}/3"
      )
      HTTParty.get(url, BASE_PARAMS)
    end
  end

  def self.update_alert(alert_id, alert_hash)
    return unless alert_id.present? && alert_hash.present?

    alerts_path = ENV['MNOHUB_PATHS_ALERTS'].gsub(':alert_id', alert_id.to_s)
    url = File.join(BASE_URL, alerts_path)

    Retryable.retryable do |attempt|
      Rails.logger.info(
        "alert_id=#{alert_id}, " \
        'action=mnohub-update-alert, ' \
        "endpoint=#{url}, " \
        "alert=#{alert_hash}, " \
        "attempt=#{attempt + 1}/3"
      )
      HTTParty.put(url, BASE_PARAMS.merge(body: { data: alert_hash }))
    end
  end
end
