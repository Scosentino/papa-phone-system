class SupportRequestMailer < ActionMailer::Base
  default from: "quinn@thekatagency.com"

  def notify_support(contact, details)
    @details = details
    @contact = contact
    mail(to: ENV['kat_phone_email_support'], subject: '[Quinn] You have a support request from a client')
  end
end
