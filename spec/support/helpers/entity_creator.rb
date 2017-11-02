# frozen_string_literal: true

# Spec Helper methods for building Entity objects (Account, Invoice, Bill, TotalsPerAccount..)
# Examples given for a transaction type, an entity type and a sub-entity type
module EntityCreator
  # def create_transaction(entity, company, balance, date, status = nil, currency = nil)
  #   attrs = {
  #     currency: currency,
  #     balance: balance,
  #     due_date: date,
  #     company_id: company.id
  #   }
  #   attrs[:status] = status if status.present?
  #   create(entity, attrs)
  # end
  #
  # def create_account(company, a_class, a_type, sub_type = nil, currency = nil)
  #   attrs = {
  #     a_class: a_class,
  #     a_type: a_type,
  #     currency: currency,
  #     company_id: company.id
  #   }
  #   attrs[:sub_type] = sub_type if sub_type.present?
  #   create(:account, attrs)
  # end
  #
  # def create_journal_line(account, net_amount, journal)
  #   total_amount = 1.1 * net_amount
  #   create(:journal_line, account: account, net_amount: net_amount, total_amount: total_amount, journal: journal)
  # end
end
