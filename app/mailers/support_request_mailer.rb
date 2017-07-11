class SupportRequestMailer < ActionMailer::Base
  default from: "andrew@joinpapa.com"

  def notify_support(contact, details)
    @details = details
    @contact = contact
    mail(to: ENV['lisa_phone_email_support'], subject: '[Lisa] You have a support request from a client')
  end
end
