# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Money::Bank::HistoricalCachingBank do
  let(:date) { Date.new(2014, 1, 1) }
  let(:from) { 'AUD' }
  let(:to) { 'HKD' }
  let(:rate) { 10.45678 }
  let(:filepath) { "#{Rails.root}/tmp/cache/currency_rates/#{date}.json" }
  let(:cache_key) { "currency_rates/#{date}" }

  around do |example|
    # Turn on caching
    ActionController::Base.perform_caching = true
    ActionController::Base.cache_store = :memory_store
    Rails.cache.clear

    example.run

    # Turn off caching
    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end

  subject { Money::Bank::HistoricalCachingBank.new }

  describe '.load_data' do
    it 'fetches data from OpenExchangeRateOtherwise and store them in cache' do
      # Stub
      module Money::Bank::OpenExchangeRatesLoader
        def load_data(date)
          @rates[date.to_s] = { foo: 'bar' }
        end
      end
      subject.clear_day_rates_from_cache(date)

      subject.load_data(date)
      expect(Rails.cache.exist?(cache_key)).to be_truthy
    end

    context 'when available' do
      it 'fetches data from cache' do
        subject.set_rate(date, from, to, rate)
        Rails.cache.write(cache_key, subject.rates[date.to_s])
        subject.rates.delete(date.to_s)

        subject.load_data(date) # should not raise VCR error
        expect(subject.get_rate(date, from, to)).to eq(rate)
      end
    end
  end
end
