# frozen_string_literal: true
# Helper for time periods manipulation
class Utility::TimeSpan
  attr_accessor :matches, :period

  TIME_PERIOD_MAPPING = {
    'd' => 'day',
    'w' => 'week',
    'm' => 'month',
    'q' => 'quarter',
    'y' => 'year'
  }.freeze

  def initialize(span)
    self.matches = /(.+)(.)/.match(span)
    self.period = TIME_PERIOD_MAPPING[matches[2]]
  end

  def time_span
    @time_span ||= if period == 'quarter'
      (3 * matches[1].to_i).months
    else
      matches[1].to_i.send(period)
    end
  end

  def self.from_period(period)
    period_letter = period.downcase.slice(0, 1)
    new("1#{period_letter}")
  end
end
