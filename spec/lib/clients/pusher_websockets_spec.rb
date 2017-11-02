# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Clients::PusherWebsockets, type: :model do
  describe '.publish_event(channel, event, data)' do
    let(:channel) { '11231454' }
    let(:event) { 'test-event' }
    let(:data) { { some: 'payload' } }
    let(:client) { double(Pusher::Client, trigger: true, :encrypted= => nil) }

    subject { described_class.publish_event(channel, event, data) }

    before do
      allow(Pusher::Client).to receive(:new).and_return(client)
    end

    it 'instantiates a Pusher::Client object' do
      expect(Pusher::Client).to receive(:new).with(
        app_id: ENV['PUSHER_APP_ID'],
        key: ENV['PUSHER_KEY'],
        secret: ENV['PUSHER_SECRET']
      )
      subject
    end

    it 'uses SSL' do
      expect(client).to receive(:encrypted=).with(true)
      subject
    end

    it 'triggers the event' do
      expect(client).to receive(:trigger).with(channel, event, data: data)
      subject
    end

    context 'when something goes wrong' do
      it 'logs an error' do
        allow(client).to receive(:trigger).and_raise(Pusher::Error)
        expect(Rails.logger).to receive(:error)
        subject
      end
    end
  end
end
