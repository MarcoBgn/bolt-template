# frozen_string_literal: true
# Used by healtcheck to verify the application is alive
class PingController < ActionController::Base
  protect_from_forgery with: :exception
  def index
    render json: { status: :ok }
  end
end
