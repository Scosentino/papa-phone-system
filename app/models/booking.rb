class Booking < ActiveRecord::Base
  belongs_to :twilio_contact

  validates_presence_of :twilio_contact
end
