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

ActiveRecord::Schema.define(version: 20160224194730) do

  create_table "application_drafts", force: :cascade do |t|
    t.integer  "application_template_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                 limit: 4
  end

  create_table "application_records", force: :cascade do |t|
    t.text     "data",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     limit: 4
    t.boolean  "reviewed"
    t.integer  "position_id", limit: 4
    t.text     "staff_note",  limit: 65535
    t.string   "ethnicity",   limit: 255
    t.string   "gender",      limit: 255
  end

  create_table "application_templates", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position_id", limit: 4
    t.boolean  "active"
    t.string   "slug",        limit: 255
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interviews", force: :cascade do |t|
    t.boolean  "hired"
    t.datetime "scheduled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",               limit: 4
    t.integer  "application_record_id", limit: 4
    t.boolean  "completed"
    t.string   "location",              limit: 255
    t.string   "interview_note",        limit: 255
  end

  create_table "positions", force: :cascade do |t|
    t.integer  "department_id",              limit: 4
    t.string   "name",                       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_interview_location", limit: 255
  end

  create_table "questions", force: :cascade do |t|
    t.text     "prompt",                  limit: 65535
    t.string   "data_type",               limit: 255
    t.boolean  "required"
    t.integer  "number",                  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "application_template_id", limit: 4
    t.integer  "application_draft_id",    limit: 4
  end

  create_table "site_texts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "text",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "spire",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "staff"
    t.string   "email",      limit: 255
  end

end
