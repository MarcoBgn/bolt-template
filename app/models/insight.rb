# frozen_string_literal: true

# == Schema Information
#
# Table name: insights
#
#  id                      :integer          not null, primary key
#  merchant_id             :string(255)
#  period_start            :datetime
#  period_end              :datetime
#  level                   :string(1)
#  avg_purchase_size       :decimal(10, 2)
#  avg_visits_per_customer :decimal(10, 2)
#  avg_spend_per_customer  :decimal(10, 2)
#  avg_industry_spend      :decimal(10, 2)
#  rep_customer_1_month    :decimal(10, 2)
#  spend_percent_mon       :decimal(6, 2)
#  spend_percent_tue       :decimal(6, 2)
#  spend_percent_wed       :decimal(6, 2)
#  spend_percent_thu       :decimal(6, 2)
#  spend_percent_fri       :decimal(6, 2)
#  spend_percent_sat       :decimal(6, 2)
#  spend_percent_sun       :decimal(6, 2)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class Insight < ApplicationRecord
  extend BaseEntity
  # == Relationships ========================================================
  belongs_to :merchant
end
