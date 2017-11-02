# :nocov:
# frozen_string_literal: true
class UnauthorizedController < ActionController::Metal
  def self.call(env)
    @respond ||= action(:respond)
    @respond.call(env)
  end

  def respond
    if request.format == 'text/html'
      ActionController::HttpAuthentication::Basic.authentication_request(self, 'Impac! API')
    else
      self.content_type = 'application/json'
      self.response_body = '{"message": "Unauthorized Action"}'
      self.status = :unauthorized
    end
  end
end
# :nocov:
