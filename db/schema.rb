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

ActiveRecord::Schema.define(version: 20140627165718) do

  create_table "ahoy_events", force: true do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.text     "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time"
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id"
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id"

  create_table "answers", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_for_papers", force: true do |t|
    t.date     "start_date",                            null: false
    t.date     "end_date",                              null: false
    t.text     "description",                           null: false
    t.integer  "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "schedule_changes",      default: false
    t.integer  "rating",                default: 3
    t.boolean  "schedule_public"
    t.boolean  "include_cfp_in_splash", default: false
  end

  create_table "campaigns", force: true do |t|
    t.integer  "conference_id"
    t.string   "name"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.string   "title",            limit: 50, default: ""
    t.text     "body"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subject"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "conferences", force: true do |t|
    t.string   "guid",                                            null: false
    t.string   "title",                                           null: false
    t.string   "short_title",                                     null: false
    t.string   "social_tag"
    t.string   "contact_email",                                   null: false
    t.string   "timezone",                                        null: false
    t.string   "html_export_path"
    t.date     "start_date",                                      null: false
    t.date     "end_date",                                        null: false
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "registration_start_date"
    t.date     "registration_end_date"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "use_dietary_choices",             default: false
    t.boolean  "use_supporter_levels",            default: false
    t.integer  "revision"
    t.boolean  "use_vpositions",                  default: false
    t.boolean  "use_vdays",                       default: false
    t.boolean  "use_difficulty_levels",           default: false
    t.boolean  "use_volunteers"
    t.string   "media_id"
    t.string   "media_type"
    t.string   "color"
    t.text     "description"
    t.text     "registration_description"
    t.text     "ticket_description"
    t.text     "sponsor_description"
    t.string   "sponsor_email"
    t.string   "twitter_url"
    t.string   "facebook_url"
    t.string   "google_url"
    t.text     "lodging_description"
    t.boolean  "make_conference_public",          default: false
    t.boolean  "include_registrations_in_splash", default: false
    t.boolean  "include_sponsors_in_splash",      default: false
    t.boolean  "include_tracks_in_splash",        default: false
    t.boolean  "include_tickets_in_splash",       default: false
    t.boolean  "include_social_media_in_splash",  default: false
    t.boolean  "include_program_in_splash",       default: false
    t.string   "banner_photo_file_name"
    t.string   "banner_photo_content_type"
    t.integer  "banner_photo_file_size"
    t.datetime "banner_photo_updated_at"
    t.boolean  "include_banner_in_splash",        default: false
    t.string   "instagram_url"
  end

  create_table "conferences_questions", id: false, force: true do |t|
    t.integer "conference_id"
    t.integer "question_id"
  end

  create_table "dietary_choices", force: true do |t|
    t.integer  "conference_id"
    t.string   "title",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "difficulty_levels", force: true do |t|
    t.integer  "conference_id"
    t.string   "title"
    t.text     "description"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_settings", force: true do |t|
    t.integer  "conference_id"
    t.boolean  "send_on_registration",                   default: true
    t.boolean  "send_on_accepted",                       default: true
    t.boolean  "send_on_rejected",                       default: true
    t.boolean  "send_on_confirmed_without_registration", default: true
    t.text     "registration_email_template"
    t.text     "accepted_email_template"
    t.text     "rejected_email_template"
    t.text     "confirmed_email_template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "registration_subject"
    t.string   "accepted_subject"
    t.string   "rejected_subject"
    t.string   "confirmed_without_registration_subject"
  end

  create_table "event_attachments", force: true do |t|
    t.integer  "event_id"
    t.string   "title",                                   null: false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.boolean  "public",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_types", force: true do |t|
    t.integer "conference_id"
    t.string  "title",                                 null: false
    t.integer "length",                  default: 30
    t.integer "minimum_abstract_length", default: 0
    t.integer "maximum_abstract_length", default: 500
    t.string  "color"
  end

  create_table "event_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "event_role", default: "participant", null: false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.string   "guid",                                         null: false
    t.integer  "conference_id"
    t.integer  "event_type_id"
    t.string   "title",                                        null: false
    t.string   "subtitle"
    t.integer  "time_slots"
    t.string   "state",                        default: "new", null: false
    t.string   "progress",                     default: "new", null: false
    t.string   "language"
    t.datetime "start_time"
    t.text     "abstract"
    t.text     "description"
    t.boolean  "public",                       default: true
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.text     "proposal_additional_speakers"
    t.integer  "track_id"
    t.integer  "room_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "media_id"
    t.string   "media_type"
    t.boolean  "require_registration"
    t.integer  "difficulty_level_id"
    t.integer  "week"
  end

  create_table "events_registrations", id: false, force: true do |t|
    t.integer "registration_id"
    t.integer "event_id"
  end

  create_table "lodgings", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "website_link"
  end

  create_table "openids", force: true do |t|
    t.string   "provider"
    t.string   "email"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: true do |t|
    t.text     "description"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qanswers", force: true do |t|
    t.integer "question_id"
    t.integer "answer_id"
  end

  create_table "qanswers_registrations", id: false, force: true do |t|
    t.integer "registration_id", null: false
    t.integer "qanswer_id",      null: false
  end

  create_table "question_types", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: true do |t|
    t.string   "title"
    t.integer  "question_type_id"
    t.integer  "conference_id"
    t.boolean  "global"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", force: true do |t|
    t.integer  "conference_id"
    t.boolean  "attending_social_events",     default: true
    t.boolean  "attending_with_partner",      default: false
    t.boolean  "using_affiliated_lodging",    default: false
    t.datetime "arrival"
    t.datetime "departure"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dietary_choice_id"
    t.text     "other_dietary_choice"
    t.boolean  "handicapped_access_required", default: false
    t.text     "other_special_needs"
    t.boolean  "attended",                    default: false
    t.boolean  "volunteer"
    t.integer  "user_id"
    t.integer  "week"
  end

  create_table "registrations_social_events", id: false, force: true do |t|
    t.integer "registration_id"
    t.integer "social_event_id"
  end

  create_table "registrations_vchoices", id: false, force: true do |t|
    t.integer "registration_id"
    t.integer "vchoice_id"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "rooms", force: true do |t|
    t.string  "guid",                         null: false
    t.integer "conference_id"
    t.string  "name",                         null: false
    t.integer "size"
    t.boolean "public",        default: true
  end

  create_table "social_events", force: true do |t|
    t.integer "conference_id"
    t.string  "title"
    t.text    "description"
    t.date    "date"
  end

  create_table "sponsors", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "website_url"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "sponsorship_level_id"
    t.integer  "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsorship_levels", force: true do |t|
    t.string   "title"
    t.integer  "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supporter_levels", force: true do |t|
    t.integer "conference_id"
    t.string  "title",         null: false
    t.string  "url"
    t.text    "description"
    t.string  "ticket_price"
  end

  create_table "supporter_registrations", force: true do |t|
    t.integer  "registration_id"
    t.integer  "supporter_level_id"
    t.integer  "conference_id"
    t.string   "name"
    t.string   "email"
    t.string   "code"
    t.boolean  "code_is_valid",      default: false
    t.datetime "created_at"
  end

  create_table "targets", force: true do |t|
    t.integer  "conference_id"
    t.integer  "campaign_id"
    t.date     "due_date"
    t.integer  "target_count"
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", force: true do |t|
    t.string   "guid",          null: false
    t.integer  "conference_id"
    t.string   "name",          null: false
    t.text     "description"
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "email_public"
    t.text     "biography"
    t.string   "nickname"
    t.string   "affiliation"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "vchoices", force: true do |t|
    t.integer "vday_id"
    t.integer "vposition_id"
  end

  create_table "vdays", force: true do |t|
    t.integer  "conference_id"
    t.date     "day"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "venues", force: true do |t|
    t.string   "guid"
    t.text     "name",                       limit: 255
    t.text     "address",                    limit: 255
    t.string   "website"
    t.text     "description"
    t.string   "offline_map_url"
    t.string   "offline_map_bounds"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "include_venue_in_splash",                default: false
    t.boolean  "include_lodgings_in_splash",             default: false
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.text     "object_changes"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

  create_table "visits", force: true do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id"

  create_table "votes", force: true do |t|
    t.integer  "event_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "vpositions", force: true do |t|
    t.integer  "conference_id"
    t.string   "title",         null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
