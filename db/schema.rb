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

ActiveRecord::Schema.define(version: 2019_06_03_143107) do

  create_table "answers", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "booth_requests", force: :cascade do |t|
    t.integer "booth_id"
    t.integer "user_id"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booth_id"], name: "index_booth_requests_on_booth_id"
    t.index ["user_id"], name: "index_booth_requests_on_user_id"
  end

  create_table "booths", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.text "reasoning"
    t.string "state"
    t.string "logo_link"
    t.string "website_url"
    t.text "submitter_relationship"
    t.integer "conference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cfps", force: :cascade do |t|
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "program_id"
    t.string "cfp_type"
    t.text "description"
    t.boolean "enable_registrations", default: false
  end

  create_table "comments", force: :cascade do |t|
    t.string "title", limit: 50, default: ""
    t.text "body"
    t.integer "commentable_id"
    t.string "commentable_type"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "subject"
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.index ["commentable_id"], name: "index_comments_on_commentable_id"
    t.index ["commentable_type"], name: "index_comments_on_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "commercials", force: :cascade do |t|
    t.string "commercial_id"
    t.string "commercial_type"
    t.integer "commercialable_id"
    t.string "commercialable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "url"
  end

  create_table "conferences", force: :cascade do |t|
    t.string "guid", null: false
    t.string "title", null: false
    t.string "short_title", null: false
    t.string "timezone", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "logo_file_name"
    t.integer "revision", default: 0, null: false
    t.boolean "use_vpositions", default: false
    t.boolean "use_vdays", default: false
    t.boolean "use_volunteers"
    t.string "color"
    t.text "events_per_week"
    t.text "description"
    t.integer "registration_limit", default: 0
    t.string "picture"
    t.integer "start_hour", default: 9
    t.integer "end_hour", default: 20
    t.integer "organization_id"
    t.integer "ticket_layout", default: 0
    t.string "custom_domain"
    t.integer "booth_limit", default: 0
    t.index ["organization_id"], name: "index_conferences_on_organization_id"
  end

  create_table "conferences_questions", id: false, force: :cascade do |t|
    t.integer "conference_id"
    t.integer "question_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "social_tag"
    t.string "email"
    t.string "facebook"
    t.string "googleplus"
    t.string "twitter"
    t.string "instagram"
    t.integer "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "sponsor_email"
    t.string "mastodon"
    t.string "youtube"
    t.string "blog"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "difficulty_levels", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "program_id"
  end

  create_table "email_settings", force: :cascade do |t|
    t.integer "conference_id"
    t.boolean "send_on_registration", default: false
    t.boolean "send_on_accepted", default: false
    t.boolean "send_on_rejected", default: false
    t.boolean "send_on_confirmed_without_registration", default: false
    t.text "registration_body"
    t.text "accepted_body"
    t.text "rejected_body"
    t.text "confirmed_without_registration_body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "registration_subject"
    t.string "accepted_subject"
    t.string "rejected_subject"
    t.string "confirmed_without_registration_subject"
    t.boolean "send_on_conference_dates_updated", default: false
    t.string "conference_dates_updated_subject"
    t.text "conference_dates_updated_body"
    t.boolean "send_on_conference_registration_dates_updated", default: false
    t.string "conference_registration_dates_updated_subject"
    t.text "conference_registration_dates_updated_body"
    t.boolean "send_on_venue_updated", default: false
    t.string "venue_updated_subject"
    t.text "venue_updated_body"
    t.boolean "send_on_cfp_dates_updated", default: false
    t.boolean "send_on_program_schedule_public", default: false
    t.string "program_schedule_public_subject"
    t.string "cfp_dates_updated_subject"
    t.text "program_schedule_public_body"
    t.text "cfp_dates_updated_body"
    t.boolean "send_on_booths_acceptance", default: false
    t.string "booths_acceptance_subject"
    t.text "booths_acceptance_body"
    t.boolean "send_on_booths_rejection", default: false
    t.string "booths_rejection_subject"
    t.text "booths_rejection_body"
    t.boolean "send_on_submitted_proposal", default: false
    t.string "submitted_proposal_subject"
    t.text "submitted_proposal_body"
  end

  create_table "event_schedules", force: :cascade do |t|
    t.integer "event_id"
    t.integer "schedule_id"
    t.integer "room_id"
    t.datetime "start_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: true
    t.index ["event_id", "schedule_id"], name: "index_event_schedules_on_event_id_and_schedule_id", unique: true
    t.index ["event_id"], name: "index_event_schedules_on_event_id"
    t.index ["room_id"], name: "index_event_schedules_on_room_id"
    t.index ["schedule_id"], name: "index_event_schedules_on_schedule_id"
  end

  create_table "event_types", force: :cascade do |t|
    t.string "title", null: false
    t.integer "length", default: 30
    t.integer "minimum_abstract_length", default: 0
    t.integer "maximum_abstract_length", default: 500
    t.string "color"
    t.string "description"
    t.integer "program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.string "event_role", default: "participant", null: false
    t.string "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.string "guid", null: false
    t.integer "event_type_id"
    t.string "title", null: false
    t.string "subtitle"
    t.string "state", default: "new", null: false
    t.string "progress", default: "new", null: false
    t.string "language"
    t.datetime "start_time"
    t.text "abstract"
    t.text "description"
    t.boolean "public", default: true
    t.text "proposal_additional_speakers"
    t.integer "track_id"
    t.integer "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "require_registration"
    t.integer "difficulty_level_id"
    t.integer "week"
    t.boolean "is_highlight", default: false
    t.integer "program_id"
    t.integer "max_attendees"
    t.integer "comments_count", default: 0, null: false
  end

  create_table "events_registrations", force: :cascade do |t|
    t.integer "registration_id"
    t.integer "event_id"
    t.boolean "attended", default: false, null: false
    t.datetime "created_at"
  end

  create_table "lodgings", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "website_link"
    t.integer "conference_id"
    t.string "picture"
  end

  create_table "openids", force: :cascade do |t|
    t.string "provider"
    t.string "email"
    t.string "uid"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "picture"
    t.text "code_of_conduct"
  end

  create_table "payments", force: :cascade do |t|
    t.string "last4"
    t.integer "amount"
    t.string "authorization_code"
    t.integer "status", default: 0, null: false
    t.integer "user_id", null: false
    t.integer "conference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "physical_tickets", force: :cascade do |t|
    t.integer "ticket_purchase_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.index ["token"], name: "index_physical_tickets_on_token", unique: true
  end

  create_table "programs", force: :cascade do |t|
    t.integer "conference_id"
    t.integer "rating", default: 0
    t.boolean "schedule_public", default: false
    t.boolean "schedule_fluid", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "languages"
    t.boolean "blind_voting", default: false
    t.datetime "voting_start_date"
    t.datetime "voting_end_date"
    t.integer "selected_schedule_id"
    t.integer "schedule_interval", default: 15, null: false
    t.index ["selected_schedule_id"], name: "index_programs_on_selected_schedule_id"
  end

  create_table "qanswers", force: :cascade do |t|
    t.integer "question_id"
    t.integer "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qanswers_registrations", id: false, force: :cascade do |t|
    t.integer "registration_id", null: false
    t.integer "qanswer_id", null: false
  end

  create_table "question_types", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: :cascade do |t|
    t.string "title"
    t.integer "question_type_id"
    t.integer "conference_id"
    t.boolean "global"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registration_periods", force: :cascade do |t|
    t.integer "conference_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", force: :cascade do |t|
    t.integer "conference_id"
    t.datetime "arrival"
    t.datetime "departure"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "other_special_needs"
    t.boolean "attended", default: false
    t.boolean "volunteer"
    t.integer "user_id"
    t.integer "week"
    t.boolean "accepted_code_of_conduct"
  end

  create_table "registrations_vchoices", id: false, force: :cascade do |t|
    t.integer "registration_id"
    t.integer "vchoice_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "quantity"
    t.integer "used", default: 0
    t.integer "conference_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description"
    t.integer "resource_id"
    t.string "resource_type"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "guid", null: false
    t.string "name", null: false
    t.integer "size"
    t.integer "venue_id", null: false
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "program_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "track_id"
    t.index ["program_id"], name: "index_schedules_on_program_id"
    t.index ["track_id"], name: "index_schedules_on_track_id"
  end

  create_table "splashpages", force: :cascade do |t|
    t.integer "conference_id"
    t.boolean "public"
    t.boolean "include_tracks"
    t.boolean "include_program"
    t.boolean "include_social_media"
    t.boolean "include_venue"
    t.boolean "include_tickets"
    t.boolean "include_registrations"
    t.boolean "include_sponsors"
    t.boolean "include_lodgings"
    t.string "banner_photo_file_name"
    t.string "banner_photo_content_type"
    t.integer "banner_photo_file_size"
    t.datetime "banner_photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "include_cfp", default: false
    t.boolean "include_booths"
    t.boolean "shuffle_highlights", default: false, null: false
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "website_url"
    t.string "logo_file_name"
    t.integer "sponsorship_level_id"
    t.integer "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "picture"
  end

  create_table "sponsorship_levels", force: :cascade do |t|
    t.string "title"
    t.integer "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_questions", force: :cascade do |t|
    t.integer "survey_id"
    t.string "title"
    t.integer "kind", default: 0
    t.integer "min_choices"
    t.integer "max_choices"
    t.text "possible_answers"
    t.boolean "mandatory", default: false
  end

  create_table "survey_replies", force: :cascade do |t|
    t.integer "survey_question_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "survey_submissions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "surveys", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "title"
    t.text "description"
    t.integer "surveyable_id"
    t.string "surveyable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "target", default: 0
    t.index ["surveyable_type", "surveyable_id"], name: "index_surveys_on_surveyable_type_and_surveyable_id"
  end

  create_table "ticket_purchases", force: :cascade do |t|
    t.integer "ticket_id"
    t.integer "conference_id"
    t.boolean "paid", default: false
    t.datetime "created_at"
    t.integer "quantity", default: 1
    t.integer "user_id"
    t.integer "payment_id"
    t.integer "week"
    t.float "amount_paid", default: 0.0
  end

  create_table "ticket_scannings", force: :cascade do |t|
    t.integer "physical_ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "conference_id"
    t.string "title", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.string "price_currency", default: "USD", null: false
    t.boolean "registration_ticket", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "guid", null: false
    t.string "name", null: false
    t.text "description"
    t.string "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "program_id"
    t.string "short_name", null: false
    t.string "state", default: "new", null: false
    t.boolean "cfp_active", null: false
    t.integer "submitter_id"
    t.integer "room_id"
    t.date "start_date"
    t.date "end_date"
    t.text "relevance"
    t.integer "selected_schedule_id"
    t.index ["room_id"], name: "index_tracks_on_room_id"
    t.index ["selected_schedule_id"], name: "index_tracks_on_selected_schedule_id"
    t.index ["submitter_id"], name: "index_tracks_on_submitter_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.boolean "email_public", default: false
    t.text "biography"
    t.string "nickname"
    t.string "affiliation"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "mobile"
    t.string "tshirt"
    t.string "languages"
    t.text "volunteer_experience"
    t.boolean "is_admin", default: false
    t.string "username"
    t.boolean "is_disabled", default: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.integer "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  create_table "vchoices", force: :cascade do |t|
    t.integer "vday_id"
    t.integer "vposition_id"
  end

  create_table "vdays", force: :cascade do |t|
    t.integer "conference_id"
    t.date "day"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", force: :cascade do |t|
    t.string "guid"
    t.string "name"
    t.string "website"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "photo_file_name"
    t.string "street"
    t.string "postalcode"
    t.string "city"
    t.string "country"
    t.string "latitude"
    t.string "longitude"
    t.integer "conference_id"
    t.string "picture"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.integer "conference_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "votes", force: :cascade do |t|
    t.integer "event_id"
    t.integer "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
  end

  create_table "vpositions", force: :cascade do |t|
    t.integer "conference_id"
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
