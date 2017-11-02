# frozen_string_literal: true
module Data::ConnecReports
  # Fetch reports from Connec!'s API
  module Client
    BASE_URL = "#{ENV['CONNEC_PROTOCOL']}://#{File.join(ENV['CONNEC_HOST'], ENV['CONNEC_PATHS_REPORTS'])}"

    def self.get(report_name, org_uid, hist_parameters, opts)
      return unless report_name.present? && org_uid.present?

      params = hist_parameters.to_h
      params[:opts] = opts if opts.present?

      url = BASE_URL.gsub(/:org_uid/, org_uid).gsub(/:report_name/, report_name)
      url = [url, params.to_query].join('?') if params.present?
      HTTParty.get(url)
    end
  end
end
