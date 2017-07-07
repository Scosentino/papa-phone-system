class CreateSupportRequests < ActiveRecord::Migration
  def change
    create_table :support_requests do |t|
      t.string :contact_type
      t.text :details

      t.timestamps
    end
  end
end
