# frozen_string_literal: true
Sidekiq.configure_server do |config|
  config.average_scheduled_poll_interval = 2
end
