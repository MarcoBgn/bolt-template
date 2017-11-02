# frozen_string_literal: true
# Tries for 3 x 3 seconds
Retryable.configure do |config|
  config.tries = 3
  config.sleep = (Rails.env == 'test' ? 0 : 3)
end
