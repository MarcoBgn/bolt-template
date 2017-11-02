# frozen_string_literal: true
# Alert object to be dispatched when a KPI is triggered or back to its normal state
class Utility::Kpis::Alert < ApplicationModel
  attr_accessor :id, :title, :subject, :messages, :service, :settings, :recipients, :sent

  define_model_callbacks :initialize, only: :after
  after_initialize :build_subject

  def initialize(attrs = {})
    run_callbacks :initialize do
      parsed_attrs = attrs.to_h.deep_symbolize_keys
      super(parsed_attrs.slice(:id, :title, :service, :settings, :recipients, :sent))
    end
  end

  def dispatch
    self.sent = !sent
    if service == 'inapp'
      # TODO: self? what should be pushed exactly?
      Clients::PusherWebsockets.publish_event(channel, event, self)
    else
      Clients::SparkpostEmails.dispatch_alert(self)
    end
    Clients::MnoHub.update_alert(id, sent: sent)
  end

  private

  def build_subject
    self.subject = if sent
      "#{title} KPI is back to normal"
    else
      "Target is reached for #{title} KPI"
    end
  end

  def config
    @config ||= settings.to_h[:pusher].to_h
  end

  def channel
    @channel ||= config[:channel]
  end

  def event
    @event ||= config[:event]
  end
end
