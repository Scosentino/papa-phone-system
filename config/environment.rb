# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.mailgun.org',
    :port => 587,
    :user_name => ENV['kat_phone_mailgun_username'],
    :password => ENV['kat_phone_mailgun_password'],
    :authentication => :plain,
}