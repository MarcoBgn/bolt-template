# frozen_string_literal: true
require Rails.root.join('lib/strategies/impac_private_strategy')

Warden::Strategies.add(:impac_private, ImpacPrivateStrategy)
