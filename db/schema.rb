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

ActiveRecord::Schema[7.1].define(version: 2026_08_19_193000) do
  create_table "activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "expedition_id"
    t.bigint "expedition_phase_id"
    t.bigint "location_id"
    t.string "name"
    t.bigint "activity_type_id"
    t.bigint "activity_status_type_id"
    t.integer "assigned_user_id"
    t.string "description"
    t.text "notes"
    t.date "start_date"
    t.date "deadline_date"
    t.integer "position"
    t.boolean "is_completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_status_type_id"], name: "index_activities_on_activity_status_type_id"
    t.index ["activity_type_id"], name: "index_activities_on_activity_type_id"
    t.index ["expedition_id"], name: "index_activities_on_expedition_id"
    t.index ["expedition_phase_id"], name: "index_activities_on_expedition_phase_id"
    t.index ["location_id"], name: "index_activities_on_location_id"
  end

  create_table "activity_contents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "activity_id"
    t.bigint "content_id"
    t.string "activity_content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_contents_on_activity_id"
    t.index ["content_id"], name: "index_activity_contents_on_content_id"
  end

  create_table "choice_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "choice_id", null: false
    t.string "name"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_id"], name: "index_choice_items_on_choice_id"
  end

  create_table "choices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "content_type"
    t.text "content"
    t.integer "author_id"
    t.boolean "is_active", default: false
    t.boolean "is_published", default: false
    t.boolean "is_sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expedition_contents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "expedition_id"
    t.bigint "content_id"
    t.string "expedition_content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_expedition_contents_on_content_id"
    t.index ["expedition_id"], name: "index_expedition_contents_on_expedition_id"
  end

  create_table "expedition_organisations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "expedition_id"
    t.bigint "organisation_id"
    t.string "expedition_organisation_type"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expedition_id"], name: "index_expedition_organisations_on_expedition_id"
    t.index ["organisation_id"], name: "index_expedition_organisations_on_organisation_id"
  end

  create_table "expedition_phases", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "expedition_id"
    t.string "name"
    t.date "start_date"
    t.date "end_date"
    t.boolean "is_completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expedition_id"], name: "index_expedition_phases_on_expedition_id"
  end

  create_table "expedition_surveys", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "expedition_id", null: false
    t.bigint "user_id"
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expedition_id"], name: "index_expedition_surveys_on_expedition_id"
  end

  create_table "expedition_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "expedition_id"
    t.bigint "user_id"
    t.string "expedition_role_type"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expedition_id"], name: "index_expedition_users_on_expedition_id"
    t.index ["user_id"], name: "index_expedition_users_on_user_id"
  end

  create_table "expeditions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "expedition_type"
    t.date "start_date"
    t.date "end_date"
    t.string "expedition_phase_type"
    t.integer "funded_amount"
    t.integer "progress"
    t.string "location"
    t.boolean "is_platform_created", default: false, null: false
    t.boolean "is_marketing_completed", default: false, null: false
    t.boolean "is_ip_agreement_signed", default: false, null: false
    t.boolean "is_impact_survey_completed", default: false, null: false
    t.boolean "is_member_agreement_completed", default: false, null: false
    t.boolean "is_skeleton", default: false, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_approved", default: false, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "designation"
    t.boolean "pre_expedition_member_agreement", default: false
    t.boolean "onboarded_to_online_platform", default: false
    t.boolean "communication_project_plan", default: false
  end

  create_table "locations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "organisation_id"
    t.string "name"
    t.string "description"
    t.string "location_type"
    t.string "address"
    t.string "city"
    t.string "country"
    t.string "postal_code"
    t.string "phone"
    t.string "longitude"
    t.string "latitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_locations_on_organisation_id"
  end

  create_table "log_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "datetime"
    t.string "event_type"
    t.text "message"
    t.string "rails_env"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisation_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id", "user_id"], name: "index_organisation_users_on_organisation_id_and_user_id", unique: true
    t.index ["organisation_id"], name: "index_organisation_users_on_organisation_id"
    t.index ["user_id"], name: "index_organisation_users_on_user_id"
  end

  create_table "organisations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "organisation_type"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_activities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "activity_id"
    t.string "survey_activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_survey_activities_on_activity_id"
    t.index ["survey_id"], name: "index_survey_activities_on_survey_id"
  end

  create_table "survey_answers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_response_id"
    t.bigint "survey_question_id"
    t.text "string_answer"
    t.string "choice_answer", limit: 2000
    t.integer "number_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"
    t.index ["survey_response_id"], name: "index_survey_answers_on_survey_response_id"
  end

  create_table "survey_expeditions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "expedition_id"
    t.string "survey_expedition_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expedition_id"], name: "index_survey_expeditions_on_expedition_id"
    t.index ["survey_id"], name: "index_survey_expeditions_on_survey_id"
  end

  create_table "survey_pages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.string "name"
    t.string "survey_page_type"
    t.string "title"
    t.text "content"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_survey_pages_on_survey_id"
  end

  create_table "survey_questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_page_id"
    t.string "name"
    t.string "label"
    t.string "survey_question_item_type"
    t.string "question_class"
    t.integer "text_lines"
    t.integer "min_value"
    t.integer "max_value"
    t.string "choice_name"
    t.boolean "multiple_answers", default: false, null: false
    t.text "hint"
    t.integer "position"
    t.string "notes", limit: 4096
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_page_id"], name: "index_survey_questions_on_survey_page_id"
  end

  create_table "survey_responses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "user_id"
    t.bigint "expedition_id"
    t.bigint "activity_id"
    t.datetime "started_at"
    t.string "survey_response_status_type"
    t.integer "last_viewed_page_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_survey_responses_on_activity_id"
    t.index ["expedition_id"], name: "index_survey_responses_on_expedition_id"
    t.index ["survey_id"], name: "index_survey_responses_on_survey_id"
    t.index ["user_id"], name: "index_survey_responses_on_user_id"
  end

  create_table "surveys", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "survey_type"
    t.string "survey_status_type"
    t.string "version"
    t.integer "author_id"
    t.string "notes", limit: 4096
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_role_choice_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "choice_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_item_id"], name: "index_user_role_choice_items_on_choice_item_id"
    t.index ["user_id", "choice_item_id"], name: "index_user_role_choice_items_on_user_id_and_choice_item_id", unique: true
    t.index ["user_id"], name: "index_user_role_choice_items_on_user_id"
  end

  create_table "user_role_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "choice_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_item_id"], name: "index_user_role_types_on_choice_item_id"
    t.index ["user_id"], name: "index_user_role_types_on_user_id"
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.string "country"
    t.string "nationality"
    t.date "birth_date"
    t.string "industry_type"
    t.string "organisation_user_role_type", default: "member"
    t.string "job_title"
    t.string "secondary_email"
    t.boolean "is_contact_only", default: false
    t.text "notes"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.string "linkedin_url"
    t.bigint "owner_id"
    t.boolean "is_contact_restricted", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["is_contact_restricted"], name: "index_users_on_is_contact_restricted"
    t.index ["owner_id"], name: "index_users_on_owner_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.string "event", null: false
    t.text "object", size: :long
    t.text "object_changes"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "activities", "choice_items", column: "activity_status_type_id"
  add_foreign_key "activities", "choice_items", column: "activity_type_id"
  add_foreign_key "expedition_surveys", "expeditions"
  add_foreign_key "organisation_users", "organisations"
  add_foreign_key "organisation_users", "users"
  add_foreign_key "user_role_choice_items", "choice_items"
  add_foreign_key "user_role_choice_items", "users"
  add_foreign_key "user_role_types", "choice_items"
  add_foreign_key "user_role_types", "users"
  add_foreign_key "users", "users", column: "owner_id"
end
