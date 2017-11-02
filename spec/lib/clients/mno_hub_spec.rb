# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Clients::MnoHub do
  describe '.get_kpis(org_uid)' do
    let(:org_uid) { 'org-fbba' }

    subject { described_class.get_kpis(org_uid) }

    before do
      allow(HTTParty).to receive(:get).and_return('data' => ['a kpi'])
      stub_const('Clients::MnoHub::BASE_URL', 'http://localhost:3000')
    end

    it 'fetches the KPIs on MnoHub endpoint' do
      expect(HTTParty).to receive(:get).with(
        'http://localhost:3000/api/mnoe/v1/organizations/org-fbba/kpis',
        headers: { 'Accept' => 'application/json' },
        basic_auth: { username: ENV['ROOT_KEY'], password: ENV['ROOT_SECRET'] }
      )
      subject
    end

    it 'returns the response from MnoHub' do
      is_expected.to eq('data' => ['a kpi'])
    end

    context 'when MnoHub fails to respond' do
      before { allow(HTTParty).to receive(:get).and_raise(Errno::ECONNREFUSED) }

      it 'retries 3 times and raises the exception' do
        expect(HTTParty).to receive(:get).exactly(3).times
        expect { subject }.to raise_error(Errno::ECONNREFUSED)
      end
    end
  end

  describe '.update_alert(alert_id, alert_hash)' do
    let(:alert_id) { 1 }
    let(:alert_hash) { { sent: true } }

    subject { described_class.update_alert(alert_id, alert_hash) }

    before do
      allow(HTTParty).to receive(:put).and_return('updated alert')
      stub_const('Clients::MnoHub::BASE_URL', 'http://localhost:3000')
    end

    it 'updates the alert on MnoHub endpoint' do
      expect(HTTParty).to receive(:put).with(
        'http://localhost:3000/api/mnoe/v1/alert/1',
        headers: { 'Accept' => 'application/json' },
        basic_auth: { username: ENV['ROOT_KEY'], password: ENV['ROOT_SECRET'] },
        body: { data: { sent: true } }
      )
      subject
    end

    it 'returns the response from MnoHub' do
      is_expected.to eq('updated alert')
    end

    context 'when MnoHub fails to respond' do
      before { allow(HTTParty).to receive(:put).and_raise(Errno::ECONNREFUSED) }

      it 'retries 3 times and raises the exception' do
        expect(HTTParty).to receive(:put).exactly(3).times
        expect { subject }.to raise_error(Errno::ECONNREFUSED)
      end
    end
  end
end
