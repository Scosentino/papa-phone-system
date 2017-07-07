class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :twilio_contact, index: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :business
      t.string :booking_type
      t.string :date
      t.string :hours
      t.string :talent
      t.string :budget

      t.timestamps
    end
  end
end
