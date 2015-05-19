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

ActiveRecord::Schema.define(version: 20150519222931) do

  create_table "application_records", force: true do |t|
    t.text     "responses"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "application_templates", force: true do |t|
    t.string   "department"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_templates", force: true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interviews", force: true do |t|
    t.boolean  "hired"
    t.datetime "scheduled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "response_fields", force: true do |t|
    t.string   "name"
    t.text     "prompt"
    t.string   "data_type"
    t.boolean  "required"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "application_template_id"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "spire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "staff"
  end

end
