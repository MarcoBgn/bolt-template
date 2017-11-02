# frozen_string_literal: true
require 'connection_pool'

# Redis gem globally exposes Redis.current
REDIS_POOL = ConnectionPool.new(size: ENV['REDIS_WORKERS'] || ENV['RAILS_MAX_THREADS'] || 10, timeout: 5) do
  Redis.new(url: ENV['REDIS_URL'])
end
