# frozen_string_literal: true
# Transaction entities, such as Invoices or Bills
module Transaction
  extend ActiveSupport::Concern

  included do
    validates :currency, presence: true
    validates :company, presence: true

    before_validation :default_currency

    def self.mapped_fields
      %w(amount currency)
    end

    def self.map(channel_id, trx_hash)
      # Ensure existence of parent company
      company = Utility::ParentEntity.new(:company, channel_id).fetch

      # Map amount and currency
      amount = trx_hash.delete(:amount).to_h
      currency = amount[:currency]
      amount = (amount[:total_amount] || amount[:net_amount]).to_f

      trx_hash.merge(
        amount: amount,
        currency: currency,
        company_id: company&.id
      )
    end

    private

    def default_currency
      self.currency ||= company&.currency
    end
  end
end
