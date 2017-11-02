# frozen_string_literal: true
require 'money/bank/historical_bank'

# This money bank extends Money::Bank::HistoricalBank
# to add filesystem caching on top of memory cache
# ---
# This bank first checks the rates cached in memory
# then the filesystem (in <rails_root>/cache/rates)
# and finally checks OpenExchangeRate for the rates
# of the day (and store them on filesystem in this case)
class Money::Bank::HistoricalCachingBank < Money::Bank::HistoricalBank
  # Clear the rates for that day in cache and in the
  # bank itself
  def clear_day_rates_from_cache(date)
    Rails.cache.delete(day_rates_cache_key(date))
    @rates.delete(date.to_s)
  end

  # Load data from cache if available
  # Otherwise call parent method (load rates from OpenExchangeRates)
  # and store the result in cache
  def load_data(date)
    @rates[date.to_s] = Rails.cache.fetch(day_rates_cache_key(date)) do
      super(date)
      @rates[date.to_s] # super return true/false
    end
  end

  private

  def day_rates_cache_key(date)
    "currency_rates/#{date}"
  end
end
