# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_07_173100) do

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "application_drafts", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "application_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.string "email"
    t.index ["application_template_id"], name: "index_application_drafts_on_application_template_id"
    t.index ["user_id", "application_template_id"], name: "index_application_drafts_on_user_id_and_application_template_id", unique: true
  end

  create_table "application_submissions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.boolean "reviewed", default: false
    t.integer "position_id"
    t.text "staff_note"
    t.string "ethnicity"
    t.string "gender"
    t.boolean "saved_for_later", default: false
    t.text "note_for_later"
    t.date "date_for_later"
    t.string "email_to_notify"
    t.text "rejection_message"
    t.index ["position_id"], name: "index_application_submissions_on_position_id"
    t.index ["user_id"], name: "index_application_submissions_on_user_id"
  end

  create_table "application_templates", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position_id"
    t.boolean "active", default: true
    t.string "slug"
    t.boolean "eeo_enabled", default: true
    t.string "email"
    t.boolean "unavailability_enabled", default: false
    t.boolean "resume_upload_enabled", default: false
    t.index ["position_id"], name: "index_application_templates_on_position_id", unique: true
  end

  create_table "departments", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "interviews", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "hired", default: false
    t.datetime "scheduled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "application_submission_id"
    t.boolean "completed", default: false
    t.string "location"
    t.text "interview_note"
    t.integer "saved_for_later", limit: 1, default: 0
    t.text "note_for_later"
    t.date "date_for_later"
    t.index ["application_submission_id"], name: "index_interviews_on_application_submission_id"
    t.index ["user_id"], name: "index_interviews_on_user_id"
  end

  create_table "positions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "department_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "default_interview_location"
    t.string "not_hiring_text"
  end

  create_table "questions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "prompt"
    t.string "data_type"
    t.boolean "required", default: false
    t.integer "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "application_template_id"
    t.integer "application_draft_id"
    t.index ["application_draft_id", "number"], name: "index_questions_on_application_draft_id_and_number", unique: true
    t.index ["application_template_id", "number"], name: "index_questions_on_application_template_id_and_number", unique: true
  end

  create_table "subscriptions", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "position_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position_id", "email"], name: "index_subscriptions_on_position_id_and_email", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "unavailabilities", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.index ["application_submission_id"], name: "index_unavailabilities_on_application_submission_id"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "spire"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "staff", default: false
    t.string "email"
    t.boolean "admin", default: false
    t.index ["spire"], name: "index_users_on_spire", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
