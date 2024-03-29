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

ActiveRecord::Schema.define(version: 20150504040424) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "permits", force: :cascade do |t|
    t.string  "permit_number"
    t.string  "streetname"
    t.string  "cross_street_1"
    t.string  "cross_street_2"
    t.string  "permit_type"
    t.string  "agent"
    t.string  "agentphone"
    t.string  "permit_purpose"
    t.date    "approved_date"
    t.string  "status"
    t.string  "cnn"
    t.integer "permit_zipcode"
    t.date    "permit_start_date"
    t.date    "permit_end_date"
    t.string  "permit_address"
    t.string  "contact"
    t.string  "contactphone"
    t.string  "inspector"
    t.boolean "curbrampwork"
    t.decimal "x"
    t.decimal "y"
    t.decimal "latitude"
    t.decimal "longitude"
  end

  create_table "temporary_signs", force: :cascade do |t|
    t.string  "address"
    t.string  "case_id"
    t.string  "category"
    t.date    "opened"
    t.date    "updated"
    t.date    "closed"
    t.string  "request_details"
    t.string  "request_type"
    t.string  "responsible_agency"
    t.decimal "latitude"
    t.decimal "longitude"
  end

end
