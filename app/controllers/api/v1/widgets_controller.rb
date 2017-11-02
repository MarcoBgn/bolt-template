# frozen_string_literal: true
# Dynamically fetches a widget, instantiates it, and render it in json
class Api::V1::WidgetsController < ApplicationController
  # TODO: dynamic discovery
  WIDGETS_LIST = %w(cash_balance cash_projection).freeze

  # :index is a discovery endpoint that does not return any confidential information and therefore should be public
  skip_before_action :authenticate!, only: [:index]

  # GET api/v1/widgets
  def index
    response = {
      widgets: WIDGETS_LIST.map do |endpoint|
        # TODO: .new({}) => can we make it cleaner? supported_layouts => constant?
        # TODO: size, name, etc: use a yml file as in Impac! v1 widgets
        widget_class = "widgets/#{endpoint}".camelize.constantize
        widget = widget_class.new({})
        {
          endpoint: endpoint,
          name: endpoint.titleize,
          width: 12,
          icon: 'line-chart',
          layouts: widget.supported_layouts
        }
      end
    }

    render json: response, status: :ok
  end

  # GET api/v1/widgets/:my_endpoint_with_slashes
  def show
    return render_bad_request('Widget endpoint does not exist') unless endpoint_param.present?
    return render_bad_request('No metadata specified') unless widget_params[:metadata].present?

    widget_params_hash = widget_params.to_h.deep_symbolize_keys
    widget = widget_klass.new(widget_params_hash)
    return render_errors(widget) if widget.invalid?

    render_success(widget)
  end

  private

  def widget_klass
    "widgets/#{endpoint_param}".classify.constantize
  end

  def widget_params
    @widgets_params ||= params.permit(
      :endpoint,
      layouts: []
    ).tap do |whitelisted|
      whitelisted[:metadata] = params[:metadata]
    end.permit!
  end

  def endpoint_param
    @endpoint_param ||= WIDGETS_LIST.find { |e| e == widget_params.require(:endpoint) }
  end

  def render_errors(widget)
    response = {
      errors: widget.errors.full_messages,
      params: widget_params
    }

    render json: response, status: :bad_request
  end

  def render_success(widget)
    response = {
      endpoint_param => widget.render,
      params: widget_params
    }

    render json: response, status: :ok
  end

  def render_bad_request(message)
    stubbed_widget = OpenStruct.new(
      errors: OpenStruct.new(
        full_messages: [message]
      )
    )
    render_errors(stubbed_widget)
  end
end
