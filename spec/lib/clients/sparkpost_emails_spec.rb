# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Clients::SparkpostEmails, type: :model do
  describe '.dispatch_alert(alert)' do
    let(:alert_recipients) do
      [
        { id: 1, email: 'test@maestrano.com', name: 'Test' },
        { id: 2, email: 'test2@maestrano.com', name: 'Test2' }
      ]
    end
    let(:alert) do
      alert = Utility::Kpis::Alert.new(service: 'inapp', recipients: alert_recipients)
      alert.subject = 'An alert subject'
      alert.messages = ['An alert message']
      alert
    end

    subject { described_class.dispatch_alert(alert) }

    let(:transmission) { double('transmission', send_message: true) }
    let(:client) { double(SparkPost::Client, transmission: transmission) }

    before { allow(SparkPost::Client).to receive(:new).and_return(client) }

    it 'instantiates a SparkPost::Client object' do
      expect(SparkPost::Client).to receive(:new)
      subject
    end

    it 'sends the message to each recipient' do
      alert.recipients.each do |r|
        expect(transmission)
          .to(receive(:send_message))
          .with(r[:email], 'impac.no-reply@maestrano.com', alert.subject, kind_of(String))
      end
      subject
    end

    context 'when something goes wrong' do
      it 'logs an error' do
        allow(transmission).to receive(:send_message).and_raise(SparkPost::DeliveryException)
        expect(Rails.logger).to receive(:error)
        subject
      end
    end
  end
end
