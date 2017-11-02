# frozen_string_literal: true
# Client for the SparkPost Emails server API.
# --------------------------------------------------------------
module Clients::SparkpostEmails
  def self.dispatch_alert(alert)
    Rails.logger.debug "action=sparkpost-dispatch-emails, recipients=#{alert.recipients}"

    alert.recipients.each do |recipient|
      response = client.transmission.send_message(
        recipient[:email],
        'impac.no-reply@maestrano.com',
        alert.subject,
        message(recipient[:name], alert)
      )
      Rails.logger.debug "action=sparkpost-dispatch-emails, recipient=#{recipient}, response=#{response}"
    end

  rescue SparkPost::DeliveryException => e
    Rails.logger.error(
      'action=sparkpost-dispatch-emails, ' \
      "recipients=#{alert.recipients}, " \
      "message=#{e.message}, " \
      "backtrace=#{e.backtrace}"
    )
  end

  def self.client
    SparkPost::Client.new
  end

  def self.message(addressee, alert)
    messages = alert.messages.map do |msg|
      "<p>#{msg}</p>"
    end.join('\n')

    %(
      <html>
        <body>
          <p>Hi #{addressee},</p>
          <p>Your projected cash position has reached the configured alert level.</p>
          #{messages}
          <p>You can access your dashboard for more details.</p>
          <br>
          <p>Thanks,<br>Maestrano</p>
        </body>
      </html>
    )
  end
  private_class_method :client, :message
end
