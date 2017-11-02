# frozen_string_literal: true
require 'matrix.rb'
# Abstract base class inherited by all the widgets
class Widgets::Base < ApplicationModel
  attr_accessor :layouts, :metadata, :hist_parameters, :currency, :organization_ids

  validates :organization_ids, presence: true

  def initialize(*attrs)
    options = attrs.extract_options!

    self.metadata = options[:metadata].to_h
    self.currency = metadata[:currency]
    self.organization_ids = metadata[:organization_ids]

    default = { from: default_from.to_s, to: default_to.to_s, period: default_period }
    self.hist_parameters = Utility::HistParameters.new(default.merge(metadata[:hist_parameters].to_h))

    # All supported layouts returned if none or only invalid are passed
    # TODO: Replace by error when no valid report
    layout_names = options.delete(:layouts).to_a & supported_layouts.to_a
    layout_names = supported_layouts.to_a unless layout_names.present?
    self.layouts = layout_names.map do |layout_name|
      "layouts/#{layout_name}".camelize.constantize.new
    end.compact
  end

  def default_from
    @default_from ||= Time.zone.today.beginning_of_year
  end

  def default_to
    @default_to ||= Time.zone.today
  end

  def default_period
    @default_period ||= 'DAILY'
  end

  # Fetches the report and calculates the widget
  # Must be implemented by the child widget | Must return self
  def compute
    raise NotImplementedError, '#compute not defined for this widget'
  end

  # Render filled layout objects
  # Returns:
  # ----------------
  # {
  #   layouts: {
  #     figure: {...},
  #     grouped_table: {...},
  #     chart: {...}
  #   }
  # }
  def render
    # TODO: render errors instead?
    return false unless valid?

    compute
    layouts.reduce({}) do |response, layout|
      fill_method = "fill_#{layout.name}".to_sym
      send(fill_method, layout)
      response.merge(layout.name => layout.render)
    end
  end

  # Constant must be defined in widget child class
  def supported_layouts
    self.class::SUPPORTED_LAYOUTS
  end

  protected

  def hist_parameters_valid?
    return true if hist_parameters.empty? || hist_parameters.valid?
    hist_parameters.errors.each do |attribute, error|
      errors.add(:hist_parameters, "#{attribute} #{error}")
    end
    false
  end

  def convert(amount_f, from_currency, at_date = Time.zone.today)
    return amount_f if from_currency == currency
    date = Chronic.parse(at_date) || Time.zone.today
    amount_f * Money.default_bank.get_rate(date, from_currency, currency)
  end

  def round(array_f)
    array_f.to_a.map { |v| v.round(2) }
  end
end
