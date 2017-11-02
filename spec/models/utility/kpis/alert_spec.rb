# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Utility::Kpis::Alert, type: :model do
  let(:attrs) do
    {
      'id' => 14,
      'impac_kpi_id' => 4,
      'recipients' => [{ 'id' => 1, 'email' => 'it@maestrano.com' }],
      'title' => 'Stub',
      'webhook' => nil,
      'service' => 'inapp',
      'sent' => false,
      'settings' => {
        'pusher' => {
          'channel' => '3502c0ab-a41b-414a-8cd5-5c64004a3b19',
          'event' => 'kpi_target_alert'
        }
      }
    }
  end

  let(:alert) { described_class.new(attrs) }

  describe 'Creation' do
    subject { alert }

    it 'sets the attributes' do
      expect(subject.id).to eq(14)
      expect(subject.title).to eq('Stub')
      expect(subject.service).to eq('inapp')
      expect(subject.settings).to eq(
        pusher: {
          channel: '3502c0ab-a41b-414a-8cd5-5c64004a3b19',
          event: 'kpi_target_alert'
        }
      )
      expect(subject.recipients).to eq([{ id: 1, email: 'it@maestrano.com' }])
      expect(subject.sent).to eq(false)
    end

    describe '#subject' do
      subject { alert.subject }

      it { is_expected.to eq('Target is reached for Stub KPI') }

      context 'when the alert has been sent before' do
        before { attrs['sent'] = true }
        it { is_expected.to eq('Stub KPI is back to normal') }
      end
    end
  end

  describe '#dispatch' do
    subject { alert.dispatch }

    before { allow(Clients::PusherWebsockets).to receive(:publish_event).and_return(true) }
    before { allow(Clients::SparkpostEmails).to receive(:dispatch_alert).and_return(true) }
    before { allow(Clients::MnoHub).to receive(:update_alert).and_return(true) }

    [false, true].each do |sent_state|
      context "when the alert #{sent_state ? 'has been sent' : 'has not been sent'} before" do
        before { attrs['sent'] = sent_state }

        it "switches the :sent flag to #{!sent_state}" do
          expect { subject }.to change { alert.sent }.to(!sent_state)
        end

        context 'with an inapp alert' do
          it 'publishes the event via Pusher' do
            expect(Clients::PusherWebsockets).to receive(:publish_event).with(
              '3502c0ab-a41b-414a-8cd5-5c64004a3b19',
              'kpi_target_alert',
              alert
            )
            subject
          end
        end

        context 'with an email alert' do
          before { attrs['service'] = 'email' }
          it 'dispatches the email via SparkPost' do
            expect(Clients::SparkpostEmails).to receive(:dispatch_alert).with(alert)
            subject
          end
        end

        it "updates the alert with sent: #{!sent_state} in MnoHub" do
          expect(Clients::MnoHub).to receive(:update_alert).with(14, sent: !sent_state)
          subject
        end
      end
    end
  end
end
