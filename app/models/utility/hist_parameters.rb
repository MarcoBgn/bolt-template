# frozen_string_literal: true
# Helper to facilitate the handling of time period parameters (historical parameters)
class Utility::HistParameters < ApplicationModel
  attr_accessor :from, :to, :period

  validate :from_before_to?

  def initialize(attrs = {})
    filtered_attributes = attrs.to_h.symbolize_keys.slice(:from, :to, :period, :time_range)
    time_range = filtered_attributes.delete(:time_range)
    super(filtered_attributes)
    parse_time_range!(time_range) if time_range
  end

  def to_h
    as_json.symbolize_keys
  end

  def empty?
    ![from, to, period].any?(&:present?)
  end

  def full?
    ![from, to, period].any?(&:blank?)
  end

  def map
    return [yield(from_date, to_date)] unless full? && valid?

    parser = Utility::TimeSpan.from_period(period)
    group_method = "end_of_#{parser.period}".to_sym

    (from_date..to_date).group_by(&group_method).map do |_, dates|
      yield(dates.first, dates.last)
    end
  end

  def from_date
    Chronic.parse(from)&.to_date
  end

  def to_date
    Chronic.parse(to)&.to_date
  end

  def interval_end_dates
    @interval_end_dates ||= map { |_i_start, i_end| i_end }
  end

  # Returns the index of the interval enclosing today's date
  def today_interval_index
    @today_interval_index ||= begin
      # time period is strictly in the past
      if to_date && to_date < Time.zone.today
        nil
      # time period is strictly in the future OR
      # time period is infinite OR
      # time period has to_date in the future but no from_date boundary OR
      # time period has from_date in the past but not to_date boundary
      elsif (from_date && from_date > Time.zone.today) || !from_date || !to_date
        0
      # time period encloses today, with from_date and to_date boundaries
      else
        interval_end_dates.index do |interval_end|
          Time.zone.today <= interval_end
        end
      end
    end
  end

  private

  def parse_time_range!(time_range)
    return unless to.present?
    time_span = Utility::TimeSpan.new(time_range).time_span
    self.from = (to_date + time_span).to_s
  end

  def from_before_to?
    return true unless from && to
    errors.add(:from, 'date should not be bigger than to date') if from_date > to_date
  end
end
