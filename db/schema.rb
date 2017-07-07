# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170704044607) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: true do |t|
    t.integer  "twilio_contact_id"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "business"
    t.string   "booking_type"
    t.string   "date"
    t.string   "hours"
    t.string   "talent"
    t.string   "budget"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookings", ["twilio_contact_id"], name: "index_bookings_on_twilio_contact_id", using: :btree

  create_table "support_requests", force: true do |t|
    t.string   "contact_type"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "twilio_contact_id"
  end

  add_index "support_requests", ["twilio_contact_id"], name: "index_support_requests_on_twilio_contact_id", using: :btree

  create_table "twilio_contacts", force: true do |t|
    t.string   "phone"
    t.string   "sms_step"
    t.string   "sms_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "twilio_messages", force: true do |t|
    t.string   "from_number"
    t.string   "to_number"
    t.text     "message_body"
    t.string   "message_type"
    t.integer  "twilio_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twilio_messages", ["twilio_contact_id"], name: "index_twilio_messages_on_twilio_contact_id", using: :btree

end
