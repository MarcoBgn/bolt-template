# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Data::ConnecReports::Client, type: :model do
  describe '.get(report_name, org_uid, hist_parameters, opts)' do
    let(:report_name) { 'accounts_summary' }
    let(:org_uid) { 'org-fbba' }
    let(:hist_parameters) { Utility::HistParameters.new(from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY') }
    let(:opts) { { an: 'option' } }

    subject { described_class.get(report_name, org_uid, hist_parameters, opts) }

    before do
      base_url = 'https://localhost:8080/api/reports/:org_uid/:report_name'
      stub_const('Data::ConnecReports::Client::BASE_URL', base_url)
    end

    it 'requests the Connec! report' do
      url = 'https://localhost:8080/api/reports/org-fbba/accounts_summary?from=2015-01-01&opts%5Ban%5D=option&period=MONTHLY&to=2015-03-31'
      expect(HTTParty).to receive(:get).with(url).and_return(true)
      subject
    end

    context 'when :report_name is nil' do
      let(:report_name) { nil }

      it { is_expected.to be_nil }

      it 'does not call Connec!' do
        expect(HTTParty).not_to receive(:get)
        subject
      end
    end

    context 'when :org_uid is nil' do
      let(:org_uid) { nil }

      it { is_expected.to be_nil }

      it 'does not call Connec!' do
        expect(HTTParty).not_to receive(:get)
        subject
      end
    end
  end
end
