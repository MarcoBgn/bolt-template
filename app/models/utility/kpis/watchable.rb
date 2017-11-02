# frozen_string_literal: true
# Element that can be "watched" on a KPI. Eg: ratio, balance, total, threshold...
class Utility::Kpis::Watchable < ApplicationModel
  attr_accessor :title, :targets

  def initialize(attrs = {})
    parsed_attrs = attrs.to_h.symbolize_keys
    parsed_attrs[:targets] ||= []
    super(parsed_attrs)
  end

  def triggered?
    @trigger_state ||= targets.any?(&:triggered?)
  end
end
