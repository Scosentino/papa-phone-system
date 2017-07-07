class TwilioContact < ActiveRecord::Base
  has_many :twilio_messages
  has_many :support_requests
  has_many :bookings
end
