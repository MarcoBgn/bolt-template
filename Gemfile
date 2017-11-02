# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# HTTP client
gem 'httparty'

# Authentication (we use warden without devise)
gem 'warden'

# Used to retry calls to other APIS
gem 'retryable'

# Use SQLite DB store aggregates
gem 'mysql2', platforms: :ruby

# Time parsing
gem 'chronic'

# New Relic monitoring - developer mode removed in v >= 4.1.0
gem 'newrelic_rpm', '~> 4.0.0'

# Currencies management
gem 'money'
gem 'money-historical-bank', git: 'https://github.com/cesar-tonnoir/money-historical-bank.git'
gem 'money-rails'

# Background jobs
gem 'sidekiq'

# Messages dispatching
# NOTE: to be exported to Even!
# using emails
gem 'sparkpost', '~> 0.1.4'
# Third-party tool to send Websockets
gem 'pusher'

# Redis caching
gem 'redis-rails'

# Facilitates querying of entities
gem 'jsonapi-resources'

group :development, :test do
  # Test suite
  gem 'rspec-rails', '~> 3.5'

  # Environment variables management
  gem 'figaro'

  # Look for N+1
  gem 'bullet'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Annotate models and routes
  gem 'annotate'

  # Security audit and coding practices - will break the build
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'rubocop', '~> 0.49.0', require: false
  gem 'rubocop-rspec', require: false

  # Suggested for better coding practices - won't break the build
  # "Rubocop for fast-ruby"
  gem 'fasterer'
  # Look for missing indexes
  gem 'lol_dba'
  # Debugging with pry-byebug
  gem 'pry-byebug'
end

group :test do
  # Additional matchers
  gem 'shoulda-matchers', require: false

  # Calculates the tests coverage
  gem 'simplecov', require: false

  # Freezes time in specs
  gem 'timecop'

  # Cleans the test database before each test
  gem 'database_cleaner'

  # Fixtures replacement
  gem 'factory_bot_rails'

  # Stub HTTP requests
  gem 'webmock'
  # Used for resources specs
  # Use base repo after https://github.com/G5/jsonapi-resources-matchers/pull/15 is merged
  gem 'jsonapi-resources-matchers', git: 'https://github.com/cesar-tonnoir/jsonapi-resources-matchers.git', branch: 'master'
end
