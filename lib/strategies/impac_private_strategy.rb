# frozen_string_literal: true
# Authenticates a request using Impac! private keys passed as basic_auth credentials
class ImpacPrivateStrategy < ::Warden::Strategies::Base
  def valid?
    basic_auth? && auth.credentials.all?(&:present?)
  end

  def authenticate!
    user = authenticate_with_basic_auth
    user.nil? ? fail('strategies.impac_private.failed') : success!(user)
  end

  private

  def authenticate_with_basic_auth
    (auth.credentials[0] == ENV['IMPAC_KEY']) & (auth.credentials[1] == ENV['IMPAC_SECRET'])
  end

  def auth
    @auth ||= Rack::Auth::Basic::Request.new(env)
  end

  def basic_auth?
    auth.provided? && auth.basic? && auth.credentials.any?
  end
end
