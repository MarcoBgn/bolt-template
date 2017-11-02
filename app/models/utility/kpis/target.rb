# frozen_string_literal: true
# Target object that helps to determine whether or not a KPI is met
class Utility::Kpis::Target < ApplicationModel
  # TODO: replace :triggered_interval_index by :triggered_at
  attr_accessor :messages, :triggered_interval_index, :currency
  attr_reader :min, :max

  def initialize(attrs = {})
    parsed_attrs = attrs.to_h.symbolize_keys
    parsed_attrs[:messages] = []
    super(parsed_attrs)
  end

  def min=(min)
    @min = min.to_f if min
  end

  def max=(max)
    @max = max.to_f if max
  end

  def triggered?
    @trigger_state ||= messages.any?
  end
end
