# frozen_string_literal: true
require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require 'action_view/railtie'
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LmiBolt
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Add Warden authentication to Rack Middleware
    # Note that on Production-like environements where the application is eagerly loaded
    # a 'frozen array modification' may occur
    begin
      puts 'Adding Warden to middleware'
      config.middleware.use Warden::Manager do |manager|
        manager.default_strategies :impac_private
        manager.failure_app = UnauthorizedController
      end
    rescue Exception => e
      puts "Error when adding rack middleware #{e.message}"
    end

    # Use Sidekiq for ActiveJob
    config.active_job.queue_adapter = :sidekiq

    # Redis caching
    if ENV['REDIS_URL']
      puts "Redis Caching is on using: #{ENV['REDIS_URL']}"
      config.cache_store = :redis_store, ENV['REDIS_URL']
    else
      puts 'Redis Caching is off'
    end

    # Load all libraries in lib directory
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/**/"]
  end
end
