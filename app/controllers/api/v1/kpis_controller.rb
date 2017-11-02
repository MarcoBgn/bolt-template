# frozen_string_literal: true
# Dynamically fetches a KPI, instantiates it, and render it in json
class Api::V1::KpisController < ApplicationController
  # TODO: dynamic discovery (should this be discovered via the available widgets?)
  KPIS_LIST = %w(cash_projection).freeze

  # :index is a discovery endpoint that does not return any confidential information and therefore should be public
  skip_before_action :authenticate!, only: [:index]

  # GET api/v1/kpis
  def index
    response = {
      kpis: KPIS_LIST.map do |endpoint|
        kpi_class = "kpis/#{endpoint}".camelize.constantize
        kpi = kpi_class.new
        {
          name: kpi.title,
          endpoint: "kpis/#{endpoint}",
          watchables: kpi_class::WATCHABLES,
          attachables: kpi_class::ATTACHABLES
        }
      end
    }

    render json: response, status: :ok
  end

  # GET api/v1/kpis/:my_endpoint_with_slashes/:watchable
  def show
    return render_bad_request('Kpi endpoint does not exist') unless endpoint_param.present?
    return render_bad_request('Kpi watchable does not exist') unless kpi_klass.can_watch?(watchable_param)

    kpi_params_hash = kpi_params.to_h.deep_symbolize_keys
    kpi = kpi_klass.new(kpi_params_hash)
    return render_errors(kpi) if kpi.invalid?

    render_success(kpi)
  end

  private

  def kpi_klass
    @kpi_klass ||= "kpis/#{endpoint_param}".classify.constantize
  end

  def kpi_params
    @kpi_params ||= params.permit(:endpoint, :watchable).tap do |whitelisted|
      whitelisted[:settings] = params[:metadata]
      whitelisted[:targets] = params[:targets] if params[:targets].present?
    end.permit!
  end

  def endpoint_param
    @endpoint_param ||= KPIS_LIST.find { |e| e == kpi_params.require(:endpoint) }
  end

  def watchable_param
    @watchable_param ||= kpi_params.require(:watchable)
  end

  def render_errors(kpi)
    response = {
      errors: kpi.errors.full_messages,
      params: kpi_params
    }

    render json: response, status: :bad_request
  end

  def render_success(kpi)
    response = {
      endpoint_param => kpi.render,
      params: kpi_params
    }

    render json: response, status: :ok
  end

  def render_bad_request(message)
    stubbed_kpi = OpenStruct.new(
      errors: OpenStruct.new(
        full_messages: [message]
      )
    )
    render_errors(stubbed_kpi)
  end
end
