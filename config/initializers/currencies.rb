# frozen_string_literal: true
require 'money'
require 'money/bank/historical_caching_bank'

Rails.logger.warn 'WARNING: no OPENEXCHANGERATES_APP_ID is configured' unless ENV['OPENEXCHANGERATES_APP_ID']

# lib/money/bank/historical_caching_bank (uses gem atwam/money-historical-bank)
Money.default_bank = Money::Bank::HistoricalCachingBank.new
