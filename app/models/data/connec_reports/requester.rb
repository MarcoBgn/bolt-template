# frozen_string_literal: true
module Data::ConnecReports
  # Facilitates the requesting of data from Connec! reports API
  module Requester
    def reports(report_name, hist_parameters, opts = {})
      @reports ||= {}
      @reports[report_name] ||= fetch_report(report_name, hist_parameters, opts)
    end

    private

    def fetch_report(report_name, hist_parameters, opts)
      organization_ids.reduce({}) do |r, channel_id|
        r.merge(channel_id => fetch_org_data(report_name, channel_id, hist_parameters, opts))
      end
    end

    def fetch_org_data(report_name, channel_id, hist_parameters, opts)
      response = Client.get(report_name, channel_id, hist_parameters, opts)
      return {} unless response&.success?
      JSON.parse response.body
    end
  end
end
