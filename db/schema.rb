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

ActiveRecord::Schema.define(version: 20140503221327) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "tablefunc"

  create_table "active_admin_comments", force: true do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "api_clients", force: true do |t|
    t.string   "name"
    t.string   "app_token"
    t.string   "app_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_access_token_request_objects", force: true do |t|
    t.integer  "access_token_id"
    t.integer  "request_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_access_token_scopes", force: true do |t|
    t.integer  "access_token_id"
    t.integer  "scope_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_access_tokens", force: true do |t|
    t.integer  "account_id"
    t.integer  "client_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connect_access_tokens", ["token"], name: "index_connect_access_tokens_on_token", unique: true, using: :btree

  create_table "connect_authorization_request_objects", force: true do |t|
    t.integer  "authorization_id"
    t.integer  "request_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_authorization_scopes", force: true do |t|
    t.integer  "authorization_id"
    t.integer  "scope_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_authorizations", force: true do |t|
    t.integer  "account_id"
    t.integer  "client_id"
    t.string   "code"
    t.string   "nonce"
    t.string   "redirect_uri"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connect_authorizations", ["code"], name: "index_connect_authorizations_on_code", unique: true, using: :btree

  create_table "connect_clients", force: true do |t|
    t.integer  "account_id"
    t.string   "identifier"
    t.string   "secret"
    t.string   "name"
    t.string   "jwks_uri"
    t.string   "sector_identifier"
    t.string   "redirect_uris"
    t.boolean  "dynamic",             default: false
    t.boolean  "native",              default: false
    t.boolean  "ppid",                default: false
    t.boolean  "superapp",            default: false
    t.datetime "expires_at"
    t.text     "raw_registered_json"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connect_clients", ["identifier"], name: "index_connect_clients_on_identifier", unique: true, using: :btree

  create_table "connect_grants", force: true do |t|
    t.integer  "client_id"
    t.integer  "account_id"
    t.integer  "scope_id"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connect_grants", ["account_id"], name: "index_connect_grants_on_account_id", using: :btree
  add_index "connect_grants", ["client_id"], name: "index_connect_grants_on_client_id", using: :btree
  add_index "connect_grants", ["scope_id"], name: "index_connect_grants_on_scope_id", using: :btree

  create_table "connect_id_token_request_objects", force: true do |t|
    t.integer  "id_token_id"
    t.integer  "request_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_id_tokens", force: true do |t|
    t.integer  "account_id"
    t.integer  "client_id"
    t.string   "nonce"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_pairwise_pseudonymous_identifiers", force: true do |t|
    t.integer  "account_id"
    t.string   "identifier"
    t.string   "sector_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_request_objects", force: true do |t|
    t.text     "jwt_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connect_scopes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connect_scopes", ["name"], name: "index_connect_scopes_on_name", unique: true, using: :btree

  create_table "data_filters", force: true do |t|
    t.string   "model"
    t.string   "field"
    t.string   "pattern_raw"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "homepage_links", force: true do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.text     "description"
    t.string   "icon"
    t.string   "url"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "ordinal"
    t.string   "group"
    t.integer  "group_ordinal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "homepage_links", ["chapter_id"], name: "index_homepage_links_on_chapter_id", using: :btree

  create_table "homepage_links_roster_roles", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "homepage_link_id"
  end

  create_table "import_logs", force: true do |t|
    t.string   "controller"
    t.string   "name"
    t.string   "url"
    t.string   "result"
    t.string   "message_subject"
    t.string   "file_name"
    t.integer  "file_size"
    t.integer  "num_rows"
    t.text     "log"
    t.text     "import_errors"
    t.string   "exception"
    t.string   "exception_message"
    t.text     "exception_trace"
    t.float    "runtime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "incidents_attachments", force: true do |t|
    t.integer  "incident_id",       null: false
    t.string   "attachment_type"
    t.string   "name"
    t.text     "description"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "incidents_attachments", ["incident_id"], name: "index_incidents_attachments_on_incident_id", using: :btree

  create_table "incidents_cas_cases", force: true do |t|
    t.integer  "cas_incident_id"
    t.string   "case_number"
    t.integer  "num_clients"
    t.string   "family_name"
    t.date     "case_last_updated"
    t.date     "case_opened"
    t.boolean  "case_is_open"
    t.string   "language"
    t.text     "narrative"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "post_incident_plans"
    t.text     "notes"
    t.datetime "last_import"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat"
    t.float    "lng"
  end

  add_index "incidents_cas_cases", ["cas_incident_id"], name: "index_incidents_cas_cases_on_cas_incident_id", using: :btree

  create_table "incidents_cas_incidents", force: true do |t|
    t.string   "dr_number"
    t.string   "cas_incident_number"
    t.string   "cas_name"
    t.integer  "dr_level"
    t.boolean  "is_dr"
    t.string   "county_name"
    t.integer  "cases_opened"
    t.integer  "cases_open"
    t.integer  "cases_closed"
    t.integer  "cases_with_assistance"
    t.integer  "cases_service_only"
    t.integer  "num_clients"
    t.integer  "phantom_cases"
    t.date     "last_date_with_open_cases"
    t.date     "incident_date"
    t.text     "notes"
    t.datetime "last_import"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chapter_id"
    t.string   "chapter_code"
    t.boolean  "ignore_incident",           default: false, null: false
  end

  add_index "incidents_cas_incidents", ["cas_incident_number"], name: "index_incidents_cas_incidents_on_cas_incident_number", unique: true, using: :btree

  create_table "incidents_case_assistance_items", force: true do |t|
    t.integer  "price_list_item_id"
    t.integer  "case_id"
    t.integer  "quantity"
    t.decimal  "total_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents_case_assistance_items", ["case_id"], name: "index_incidents_case_assistance_items_on_case_id", using: :btree
  add_index "incidents_case_assistance_items", ["price_list_item_id"], name: "index_incidents_case_assistance_items_on_price_list_item_id", using: :btree

  create_table "incidents_cases", force: true do |t|
    t.integer  "incident_id"
    t.string   "cas_case_number"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "unit"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "lat"
    t.float    "lng"
    t.string   "phone_number"
    t.integer  "num_adults"
    t.integer  "num_children"
    t.decimal  "total_amount"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cac_masked"
  end

  add_index "incidents_cases", ["incident_id"], name: "index_incidents_cases_on_incident_id", using: :btree

  create_table "incidents_dat_incidents", force: true do |t|
    t.integer  "incident_id",             null: false
    t.string   "incident_call_type"
    t.string   "verified_by"
    t.integer  "num_people_injured"
    t.integer  "num_people_hospitalized"
    t.integer  "num_people_deceased"
    t.string   "cross_street"
    t.integer  "units_affected"
    t.integer  "units_minor"
    t.integer  "units_major"
    t.integer  "units_destroyed"
    t.text     "services"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "structure_type"
    t.integer  "completed_by_id"
    t.text     "languages"
    t.hstore   "resources"
  end

  add_index "incidents_dat_incidents", ["incident_id"], name: "index_incidents_dat_incidents_on_incident_id", unique: true, using: :btree

  create_table "incidents_deployments", force: true do |t|
    t.integer  "person_id"
    t.string   "gap"
    t.string   "group"
    t.string   "activity"
    t.string   "position"
    t.string   "qual"
    t.date     "date_first_seen"
    t.date     "date_last_seen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "disaster_id"
  end

  create_table "incidents_disasters", force: true do |t|
    t.integer  "vc_incident_id"
    t.string   "dr_number"
    t.integer  "fiscal_year"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "incidents_dispatch_log_items", force: true do |t|
    t.integer  "dispatch_log_id"
    t.datetime "action_at"
    t.string   "action_type"
    t.string   "recipient"
    t.string   "operator"
    t.string   "result"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents_dispatch_log_items", ["dispatch_log_id"], name: "index_incidents_dispatch_log_items_on_dispatch_log_id", using: :btree

  create_table "incidents_dispatch_logs", force: true do |t|
    t.string   "incident_number"
    t.integer  "chapter_id"
    t.integer  "incident_id"
    t.datetime "received_at"
    t.datetime "delivered_at"
    t.string   "delivered_to"
    t.string   "incident_type"
    t.string   "address"
    t.string   "cross_street"
    t.string   "county_name"
    t.string   "displaced"
    t.string   "services_requested"
    t.string   "agency"
    t.string   "contact_name"
    t.string   "contact_phone"
    t.string   "caller_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents_dispatch_logs", ["chapter_id"], name: "index_incidents_dispatch_logs_on_chapter_id", using: :btree
  add_index "incidents_dispatch_logs", ["incident_id"], name: "index_incidents_dispatch_logs_on_incident_id", using: :btree

  create_table "incidents_event_logs", force: true do |t|
    t.integer  "incident_id"
    t.integer  "person_id"
    t.string   "event"
    t.datetime "event_time"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
  end

  add_index "incidents_event_logs", ["incident_id"], name: "index_incidents_event_logs_on_incident_id", using: :btree
  add_index "incidents_event_logs", ["person_id"], name: "index_incidents_event_logs_on_person_id", using: :btree

  create_table "incidents_incidents", force: true do |t|
    t.integer  "chapter_id"
    t.string   "incident_number"
    t.string   "incident_type"
    t.string   "cas_incident_number"
    t.date     "date"
    t.integer  "num_adults"
    t.integer  "num_children"
    t.integer  "num_families"
    t.integer  "num_cases"
    t.string   "incident_description"
    t.text     "narrative_brief"
    t.text     "narrative"
    t.string   "address"
    t.string   "cross_street"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "lat"
    t.float    "lng"
    t.string   "idat_incident_id"
    t.string   "idat_incident_rev"
    t.datetime "last_idat_sync"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_no_incident_warning"
    t.boolean  "ignore_incident_report"
    t.boolean  "evac_partner_used",        default: false
    t.boolean  "hotel_partner_used",       default: false
    t.boolean  "shelter_partner_used",     default: false
    t.boolean  "feeding_partner_used",     default: false
    t.integer  "area_id"
    t.string   "county"
    t.string   "status",                                   null: false
    t.date     "response_date"
  end

  add_index "incidents_incidents", ["cas_incident_number"], name: "index_incidents_incidents_on_cas_incident_number", using: :btree
  add_index "incidents_incidents", ["chapter_id", "incident_number"], name: "index_incidents_incidents_on_chapter_id_incident_number", unique: true, using: :btree
  add_index "incidents_incidents", ["chapter_id"], name: "index_incidents_incidents_on_chapter_id", using: :btree
  add_index "incidents_incidents", ["incident_number"], name: "index_incidents_incidents_on_incident_number", using: :btree

  create_table "incidents_notification_subscriptions", force: true do |t|
    t.integer  "person_id"
    t.integer  "county_id"
    t.string   "notification_type"
    t.boolean  "persistent",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.hstore   "options"
    t.string   "frequency"
    t.date     "last_sent"
  end

  add_index "incidents_notification_subscriptions", ["county_id"], name: "index_incidents_notification_subscriptions_on_county_id", using: :btree
  add_index "incidents_notification_subscriptions", ["person_id"], name: "index_incidents_notification_subscriptions_on_person_id", using: :btree

  create_table "incidents_partner_uses", force: true do |t|
    t.integer  "incident_id"
    t.integer  "partner_id"
    t.string   "role"
    t.decimal  "hotel_rate"
    t.integer  "hotel_rooms"
    t.integer  "meals_served"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents_partner_uses", ["incident_id"], name: "index_incidents_partner_uses_on_incident_id", using: :btree
  add_index "incidents_partner_uses", ["partner_id"], name: "index_incidents_partner_uses_on_partner_id", using: :btree

  create_table "incidents_price_list_items", force: true do |t|
    t.integer  "item_class"
    t.string   "name"
    t.string   "type"
    t.decimal  "unit_price"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "incidents_responder_assignments", force: true do |t|
    t.integer  "person_id"
    t.integer  "incident_id"
    t.string   "role"
    t.string   "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "was_flex",    default: false
  end

  add_index "incidents_responder_assignments", ["incident_id"], name: "index_incidents_responder_assignments_on_incident_id", using: :btree
  add_index "incidents_responder_assignments", ["person_id"], name: "index_incidents_responder_assignments_on_person_id", using: :btree

  create_table "incidents_vehicle_uses", force: true do |t|
    t.integer  "vehicle_id"
    t.integer  "incident_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "incidents_vehicle_uses", ["incident_id"], name: "index_incidents_vehicle_uses_on_incident_id", using: :btree
  add_index "incidents_vehicle_uses", ["vehicle_id"], name: "index_incidents_vehicle_uses_on_vehicle_id", using: :btree

  create_table "logistics_vehicles", force: true do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.string   "category"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lookups", force: true do |t|
    t.integer  "chapter_id"
    t.string   "scope"
    t.string   "name",       null: false
    t.string   "value",      null: false
    t.integer  "ordinal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lookups", ["chapter_id"], name: "index_lookups_on_chapter_id", using: :btree

  create_table "motds", force: true do |t|
    t.integer  "chapter_id"
    t.datetime "begins"
    t.datetime "ends"
    t.string   "cookie_code"
    t.text     "html"
    t.string   "dialog_class"
    t.integer  "cookie_version"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "path_regex_raw"
  end

  add_index "motds", ["chapter_id"], name: "index_motds_on_chapter_id", using: :btree

  create_table "named_queries", force: true do |t|
    t.string   "name"
    t.string   "token"
    t.text     "parameters"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "named_queries", ["name", "token"], name: "index_named_queries_on_name_and_token", using: :btree

  create_table "partners_partners", force: true do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roster_cell_carriers", force: true do |t|
    t.string   "name"
    t.string   "sms_gateway"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pager"
  end

  create_table "roster_chapters", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "short_name"
    t.string   "time_zone_raw"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vc_username"
    t.string   "vc_password"
    t.string   "vc_position_filter"
    t.hstore   "config"
    t.integer  "vc_unit"
  end

  create_table "roster_counties", force: true do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.string   "abbrev"
    t.string   "county_code"
    t.string   "fips_code"
    t.string   "gis_name"
    t.string   "vc_regex_raw"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roster_county_memberships", force: true do |t|
    t.integer "county_id"
    t.integer "person_id"
    t.boolean "persistent"
  end

  create_table "roster_people", force: true do |t|
    t.integer  "chapter_id"
    t.integer  "primary_county_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "secondary_email"
    t.string   "username"
    t.string   "home_phone"
    t.string   "cell_phone"
    t.string   "work_phone"
    t.string   "alternate_phone"
    t.string   "sms_phone"
    t.string   "phone_1_preference"
    t.string   "phone_2_preference"
    t.string   "phone_3_preference"
    t.string   "phone_4_preference"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "vc_id"
    t.integer  "vc_member_number"
    t.integer  "home_phone_carrier_id"
    t.integer  "work_phone_carrier_id"
    t.integer  "cell_phone_carrier_id"
    t.integer  "alternate_phone_carrier_id"
    t.integer  "sms_phone_carrier_id"
    t.boolean  "home_phone_disable"
    t.boolean  "work_phone_disable"
    t.boolean  "cell_phone_disable"
    t.boolean  "alternate_phone_disable"
    t.boolean  "sms_phone_disable"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.binary   "persistence_token"
    t.datetime "last_login"
    t.datetime "vc_imported_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat"
    t.float    "lng"
    t.boolean  "vc_is_active",               default: true
    t.string   "gap_primary"
    t.string   "gap_secondary"
    t.string   "gap_tertiary"
    t.datetime "vc_last_login"
    t.datetime "vc_last_profile_update"
  end

  add_index "roster_people", ["vc_id"], name: "idx_vc_id", using: :btree

  create_table "roster_position_memberships", force: true do |t|
    t.integer "position_id"
    t.integer "person_id"
    t.boolean "persistent"
  end

  add_index "roster_position_memberships", ["person_id"], name: "index_roster_position_memberships_on_person_id", using: :btree

  create_table "roster_positions", force: true do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.string   "vc_regex_raw"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",         default: false
    t.string   "watchfire_role"
    t.string   "abbrev"
  end

  create_table "roster_positions_roles", id: false, force: true do |t|
    t.integer "position_id"
    t.integer "role_id"
  end

  create_table "roster_positions_scheduler_shifts", id: false, force: true do |t|
    t.integer "shift_id"
    t.integer "position_id"
  end

  create_table "roster_role_scopes", force: true do |t|
    t.integer  "role_id"
    t.string   "scope"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roster_role_scopes", ["role_id"], name: "index_roster_role_scopes_on_role_id", using: :btree

  create_table "roster_roles", force: true do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.string   "grant_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduler_dispatch_configs", force: true do |t|
    t.integer  "county_id"
    t.integer  "backup_first_id"
    t.integer  "backup_second_id"
    t.integer  "backup_third_id"
    t.integer  "backup_fourth_id"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             null: false
  end

  add_index "scheduler_dispatch_configs", ["backup_first_id"], name: "index_scheduler_dispatch_configs_on_backup_first_id", using: :btree
  add_index "scheduler_dispatch_configs", ["backup_fourth_id"], name: "index_scheduler_dispatch_configs_on_backup_fourth_id", using: :btree
  add_index "scheduler_dispatch_configs", ["backup_second_id"], name: "index_scheduler_dispatch_configs_on_backup_second_id", using: :btree
  add_index "scheduler_dispatch_configs", ["backup_third_id"], name: "index_scheduler_dispatch_configs_on_backup_third_id", using: :btree
  add_index "scheduler_dispatch_configs", ["county_id"], name: "index_scheduler_dispatch_configs_on_county_id", using: :btree

  create_table "scheduler_dispatch_configs_admin_notifications", id: false, force: true do |t|
    t.integer "scheduler_dispatch_config_id"
    t.integer "roster_person_id"
  end

  create_table "scheduler_flex_schedules", force: true do |t|
    t.integer  "person_id"
    t.boolean  "available_sunday_day"
    t.boolean  "available_sunday_night"
    t.boolean  "available_monday_day"
    t.boolean  "available_monday_night"
    t.boolean  "available_tuesday_day"
    t.boolean  "available_tuesday_night"
    t.boolean  "available_wednesday_day"
    t.boolean  "available_wednesday_night"
    t.boolean  "available_thursday_day"
    t.boolean  "available_thursday_night"
    t.boolean  "available_friday_day"
    t.boolean  "available_friday_night"
    t.boolean  "available_saturday_day"
    t.boolean  "available_saturday_night"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduler_flex_schedules", ["person_id"], name: "index_scheduler_flex_schedules_on_person_id", using: :btree

  create_table "scheduler_notification_settings", force: true do |t|
    t.integer  "email_advance_hours"
    t.integer  "sms_advance_hours"
    t.integer  "sms_only_after",            default: 0
    t.integer  "sms_only_before",           default: 86400
    t.boolean  "send_email_invites"
    t.string   "calendar_api_token"
    t.text     "shift_notification_phones"
    t.boolean  "email_swap_requested"
    t.boolean  "email_all_swaps"
    t.boolean  "email_calendar_signups"
    t.integer  "email_all_shifts_at"
    t.integer  "sms_all_shifts_at"
    t.date     "last_all_shifts_email"
    t.date     "last_all_shifts_sms"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_all_swaps_daily"
  end

  add_index "scheduler_notification_settings", ["calendar_api_token"], name: "index_scheduler_notification_settings_on_calendar_api_token", unique: true, using: :btree

  create_table "scheduler_shift_assignments", force: true do |t|
    t.integer  "person_id"
    t.integer  "shift_id"
    t.date     "date"
    t.boolean  "email_invite_sent",   default: false
    t.boolean  "email_reminder_sent", default: false
    t.boolean  "sms_reminder_sent",   default: false
    t.boolean  "available_for_swap",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "synced",              default: false
  end

  add_index "scheduler_shift_assignments", ["date", "person_id", "shift_id"], name: "index_scheduler_shift_assignment_fields", unique: true, using: :btree
  add_index "scheduler_shift_assignments", ["person_id"], name: "index_scheduler_shift_assignments_on_person_id", using: :btree
  add_index "scheduler_shift_assignments", ["shift_id", "date"], name: "index_scheduler_shift_assignments_on_shift_id_date", using: :btree
  add_index "scheduler_shift_assignments", ["shift_id"], name: "index_scheduler_shift_assignments_on_shift_id", using: :btree

  create_table "scheduler_shift_categories", force: true do |t|
    t.integer  "chapter_id"
    t.string   "name"
    t.boolean  "show",       default: false, null: false
    t.integer  "ordinal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduler_shift_categories", ["chapter_id"], name: "index_scheduler_shift_categories_on_chapter_id", using: :btree

  create_table "scheduler_shift_groups", force: true do |t|
    t.string   "name"
    t.string   "period"
    t.integer  "start_offset"
    t.integer  "end_offset"
    t.integer  "chapter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active_sunday",    default: true, null: false
    t.boolean  "active_monday",    default: true, null: false
    t.boolean  "active_tuesday",   default: true, null: false
    t.boolean  "active_wednesday", default: true, null: false
    t.boolean  "active_thursday",  default: true, null: false
    t.boolean  "active_friday",    default: true, null: false
    t.boolean  "active_saturday",  default: true, null: false
  end

  add_index "scheduler_shift_groups", ["chapter_id"], name: "index_scheduler_shift_groups_on_chapter_id", using: :btree

  create_table "scheduler_shifts", force: true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.integer  "shift_group_id"
    t.integer  "max_signups"
    t.integer  "county_id"
    t.integer  "ordinal"
    t.integer  "spreadsheet_ordinal"
    t.integer  "dispatch_role"
    t.date     "shift_begins"
    t.date     "shift_ends"
    t.date     "signups_frozen_before"
    t.integer  "max_advance_signup"
    t.date     "signups_available_before"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "min_desired_signups"
    t.boolean  "ignore_county",            default: false
    t.integer  "min_advance_signup",       default: 0,     null: false
    t.integer  "shift_category_id"
  end

  add_index "scheduler_shifts", ["county_id"], name: "index_scheduler_shifts_on_county_id", using: :btree
  add_index "scheduler_shifts", ["shift_group_id"], name: "index_scheduler_shifts_on_shift_group_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "root_type"
    t.integer  "root_id"
    t.integer  "chapter_id",     null: false
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
