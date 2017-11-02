# frozen_string_literal: true
# Abstract base class inherited by all the widgets
class Kpis::Base < ApplicationModel
  attr_accessor :title, :settings, :hist_parameters, :currency, :watchables, :alerts

  # Constants to be defined in child class
  # BASE_ENTITIES = [String] - List of entities on which the KPI calculation is based
  # WATCHABLES = [Symbol] -- List of watchables available for the KPI
  # ATTACHABLES = [String] -- List of widgets that can have the KPI attached to

  # TODO: dynamic?
  KPIS_LIST = {}.freeze

  def initialize(attrs = {})
    options = attrs.deep_symbolize_keys

    self.title = self.class.name.demodulize.titleize
    self.settings = options[:settings].to_h
    self.hist_parameters = Utility::HistParameters.new(settings[:hist_parameters])
    self.currency = settings[:currency]

    self.watchables = options[:targets].to_h.map do |watchable, targets_array|
      valid_watchable = self.class::WATCHABLES.find { |w| w == watchable }
      next unless valid_watchable.present?

      targets = targets_array.map { |t_hash| Utility::Kpis::Target.new(t_hash) }
      Utility::Kpis::Watchable.new(title: valid_watchable, targets: targets)
    end.to_a.compact

    self.alerts = options[:alerts].to_a.map do |alert_hash|
      Utility::Kpis::Alert.new(alert_hash.merge(title: title))
    end

    block_given? ? yield : self
  end

  # def self.based_on_any?(entities_names)
  #   entities_names.any? { |entity_name| BASE_ENTITIES.include?(entity_name) }
  # end

  def compute
    if valid?
      watchables.each do |watchable|
        watchable.targets.each do |target|
          next unless target.currency.present?
          target.min = convert(target.min, target.currency).round(2) if target.min
          target.max = convert(target.max, target.currency).round(2) if target.max
        end
        send("assess_#{watchable.title}!", watchable)
      end
    end
    self
  end

  # Render KPI results
  # Returns:
  # ----------------
  # {
  #   triggered: true,
  #   watchables: [{
  #     title: 'threshold',
  #     "targets": [{
  #       "min": 13700,
  #       "messages": [ ... ],
  #       "triggered_interval_index": 1,
  #       "trigger_state": true
  #     }],
  #    "trigger_state": true
  #   }]
  # }
  def render
    compute
    { triggered: triggered?, watchables: watchables.as_json }
  end

  # The KPI is considered triggered if any target of any watchable is met
  def triggered?
    @trigger_state ||= watchables.any?(&:triggered?)
  end

  # Dispatch alert if:
  #    - alert not sent and watchable triggered
  # OR - alert sent and watchable not triggered ("back to normal")
  def dispatch_alerts
    compute
    alerts.each do |alert|
      watchables.select { |watchable| alert.sent != watchable.triggered? }.each do |watchable|
        send("format_alert_for_#{watchable.title}!", alert, watchable)
        alert.dispatch
      end
    end
  end

  def self.can_watch?(watchable)
    self::WATCHABLES.include?(watchable.to_sym)
  end

  protected

  def convert(amount_f, from_currency, at_date = Time.zone.today)
    return amount_f if from_currency == currency
    date = Chronic.parse(at_date) || Time.zone.today
    amount_f * Money.default_bank.get_rate(date, from_currency, currency)
  end
end
