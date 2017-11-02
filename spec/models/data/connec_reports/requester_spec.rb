require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Data::ConnecReports::Requester, type: :model do
  let(:widget_class) do
    # Stub widget class
    class MyWidget
      include Data::ConnecReports::Requester

      attr_accessor :base_reports, :organization_ids

      def initialize
        self.organization_ids = %w(org-fbba org-fbbi)
      end
    end

    MyWidget
  end
  let(:widget) { widget_class.new }

  describe '#reports(report_name, hist_parameters, opts)' do
    let(:report_name) { 'report_test' }
    let(:hist_parameters) { Utility::HistParameters.new(from: '2015-01-01', to: '2015-03-31', period: 'MONTHLY') }
    let(:opts) { { an: 'option' } }

    subject { widget.reports(report_name, hist_parameters, opts) }

    before do
      allow(Data::ConnecReports::Client).to receive(:get) do |report_name, org_uid|
        OpenStruct.new(success?: true, body: { report: "#{report_name} for #{org_uid}" }.to_json)
      end
    end

    it 'fetches and memoizes the report from Connec!' do
      expect(Data::ConnecReports::Client).to receive(:get).once.with('report_test', 'org-fbba', hist_parameters, opts)
      expect(Data::ConnecReports::Client).to receive(:get).once.with('report_test', 'org-fbbi', hist_parameters, opts)
      subject
      widget.reports(report_name, hist_parameters, opts)
    end

    it 'returns a hash for each organization' do
      is_expected.to eq(
        'org-fbba' => { 'report' => 'report_test for org-fbba' },
        'org-fbbi' => { 'report' => 'report_test for org-fbbi' }
      )
    end

    context 'when the request is not successful' do
      before do
        allow(Data::ConnecReports::Client).to receive(:get).with('report_test', 'org-fbbi', hist_parameters, opts) do
          OpenStruct.new(success?: false)
        end
      end

      it 'returns an empty hash for the failed report' do
        is_expected.to eq(
          'org-fbba' => { 'report' => 'report_test for org-fbba' },
          'org-fbbi' => {}
        )
      end
    end
  end
end
