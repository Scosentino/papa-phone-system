class AddTwilioContactReferenceToSupportRequest < ActiveRecord::Migration
  def change
    add_reference :support_requests, :twilio_contact, index: true
  end
end
