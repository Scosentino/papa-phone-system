class CreateTwilioMessages < ActiveRecord::Migration
  def change
    create_table :twilio_messages do |t|
      t.string :from_number
      t.string :to_number
      t.text :message_body
      t.string :message_type
      t.references :twilio_contact, index: true

      t.timestamps
    end
  end
end
