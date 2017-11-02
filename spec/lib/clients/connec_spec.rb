# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Clients::Connec do
  describe '.get_entity(channel_id, entity_name, entity_id)' do
    RSpec.shared_examples_for "#{described_class}: cancelled request" do
      it 'does not call Connec!' do
        expect(HTTParty).to_not receive(:get)
        subject
      end

      it 'does not yield' do
        expect { |b| described_class.get_entity(channel_id, entity_name, entity_id, &b) }.to_not yield_control
      end

      it { is_expected.to be_nil }
    end

    let(:channel_id) { 'org-fbba' }
    let(:entity_name) { 'invoices' }
    let(:entity_id) { 'e2943be0-606e-0135-edd6-7caa147a84c2' }
    let(:invoice_hash) { { 'hash' => 'from_connec' } }
    let(:connec_response) { double(success?: true, parsed_response: { 'invoices' => invoice_hash }) }

    subject { described_class.get_entity(channel_id, entity_name, entity_id) {} }

    before do
      stub_const("#{described_class}::BASE_URL", 'http://localhost:8080')
      allow(HTTParty).to receive(:get).and_return(connec_response)
    end

    it 'fetches the entity on Connec! API v2' do
      expect(HTTParty).to receive(:get).with(
        "http://localhost:8080/api/v2/#{channel_id}/invoices/#{entity_id}",
        headers: { 'Accept' => 'application/json' },
        basic_auth: { username: ENV['ROOT_KEY'], password: ENV['ROOT_SECRET'] }
      )
      subject
    end

    it 'yields the entity hash received from Connec!' do
      expect { |b| described_class.get_entity(channel_id, entity_name, entity_id, &b) }.to yield_with_args(invoice_hash)
    end

    context 'with no channel_id' do
      let(:channel_id) { nil }
      it_behaves_like "#{described_class}: cancelled request"
    end

    context 'with no entity_name' do
      let(:entity_name) { nil }
      it_behaves_like "#{described_class}: cancelled request"
    end

    context 'when Connec! fails to respond' do
      before { allow(HTTParty).to receive(:get).and_raise(Errno::ECONNREFUSED) }

      it 'retries 3 times and raises the exception' do
        expect(HTTParty).to receive(:get).exactly(3).times
        expect { subject }.to raise_error(Errno::ECONNREFUSED)
      end
    end

    context 'when the response fron Connec! is unsuccessful' do
      let(:connec_response) { double(success?: false, code: 400) }

      it 'does not yield' do
        expect { |b| described_class.get_entity(channel_id, entity_name, entity_id, &b) }.to_not yield_control
      end

      it { is_expected.to be_nil }
    end
  end
end
