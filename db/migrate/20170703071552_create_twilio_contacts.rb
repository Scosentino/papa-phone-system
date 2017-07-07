class CreateTwilioContacts < ActiveRecord::Migration
  def change
    create_table :twilio_contacts do |t|
      t.string :phone
      t.string :sms_step
      t.string :sms_contact

      t.timestamps
    end
  end
end
