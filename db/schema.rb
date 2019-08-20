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

ActiveRecord::Schema.define(version: 2019_08_20_153130) do

  create_table "application_drafts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "email"
  end

  create_table "application_submissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.boolean "reviewed"
    t.integer "position_id"
    t.text "staff_note"
    t.string "ethnicity"
    t.string "gender"
    t.boolean "saved_for_later", default: false
    t.text "note_for_later"
    t.date "date_for_later"
    t.string "email_to_notify"
  end

  create_table "application_templates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position_id"
    t.boolean "active", default: true
    t.string "slug"
    t.boolean "eeo_enabled", default: true
    t.string "email"
    t.boolean "unavailability_enabled"
  end

  create_table "departments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interviews", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "hired"
    t.datetime "scheduled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "application_submission_id"
    t.boolean "completed"
    t.string "location"
    t.text "interview_note"
  end

  create_table "positions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "department_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "default_interview_location"
    t.string "not_hiring_text"
  end

  create_table "questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "prompt"
    t.string "data_type"
    t.boolean "required"
    t.integer "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "application_template_id"
    t.integer "application_draft_id"
  end

  create_table "site_texts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
  end

  create_table "subscriptions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "position_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "unavailabilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "sunday"
    t.string "monday"
    t.string "tuesday"
    t.string "wednesday"
    t.string "thursday"
    t.string "friday"
    t.string "saturday"
    t.integer "application_submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "spire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "staff"
    t.string "email"
    t.boolean "admin"
    t.bigint "parent_id"
    t.bigint "child_id"
    t.index ["child_id"], name: "index_users_on_child_id"
    t.index ["parent_id"], name: "index_users_on_parent_id"
  end

end
