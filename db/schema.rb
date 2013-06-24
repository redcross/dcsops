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

ActiveRecord::Schema.define(version: 20130624073542) do

  create_table "active_admin_comments", force: true do |t|
    t.string    "resource_id",   null: false
    t.string    "resource_type", null: false
    t.integer   "author_id"
    t.string    "author_type"
    t.text      "body"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "import_logs", force: true do |t|
    t.string    "controller"
    t.string    "name"
    t.string    "url"
    t.string    "result"
    t.string    "message_subject"
    t.string    "file_name"
    t.integer   "file_size"
    t.integer   "num_rows"
    t.text      "log"
    t.text      "import_errors"
    t.string    "exception"
    t.string    "exception_message"
    t.text      "exception_trace"
    t.float     "runtime"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "incidents_cas_cases", force: true do |t|
    t.integer   "cas_incident_id"
    t.string    "case_number"
    t.integer   "num_clients"
    t.string    "family_name"
    t.date      "case_last_updated"
    t.date      "case_opened"
    t.boolean   "case_is_open"
    t.string    "language"
    t.text      "narrative"
    t.string    "address"
    t.string    "city"
    t.string    "state"
    t.string    "post_incident_plans"
    t.text      "notes"
    t.timestamp "last_import"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_cas_cases", ["cas_incident_id"], name: "index_incidents_cas_cases_on_cas_incident_id"

  create_table "incidents_cas_incidents", force: true do |t|
    t.string    "dr_number"
    t.string    "cas_incident_number"
    t.string    "cas_name"
    t.integer   "dr_level"
    t.boolean   "is_dr"
    t.string    "county_name"
    t.integer   "cases_opened"
    t.integer   "cases_open"
    t.integer   "cases_closed"
    t.integer   "cases_with_assistance"
    t.integer   "cases_service_only"
    t.integer   "num_clients"
    t.integer   "phantom_cases"
    t.date      "last_date_with_open_cases"
    t.integer   "incident_id"
    t.date      "incident_date"
    t.text      "notes"
    t.timestamp "last_import"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_cas_incidents", ["incident_id"], name: "index_incidents_cas_incidents_on_incident_id"

  create_table "incidents_dat_incidents", force: true do |t|
    t.integer   "incident_id"
    t.string    "incident_type"
    t.string    "incident_call_type"
    t.string    "verified_by"
    t.integer   "num_adults"
    t.integer   "num_children"
    t.integer   "num_families"
    t.integer   "num_people_injured"
    t.integer   "num_people_hospitalized"
    t.integer   "num_people_deceased"
    t.timestamp "responder_notified"
    t.timestamp "responder_arrived"
    t.timestamp "responder_departed"
    t.string    "address"
    t.string    "cross_street"
    t.string    "neighborhood"
    t.string    "city"
    t.string    "state"
    t.string    "zip"
    t.decimal   "lat"
    t.decimal   "lng"
    t.integer   "units_affected"
    t.integer   "units_minor"
    t.integer   "units_major"
    t.integer   "units_destroyed"
    t.text      "narrative"
    t.text      "services"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "structure_type"
    t.integer   "comfort_kits_used"
    t.integer   "blankets_used"
    t.integer   "completed_by_id"
  end

  add_index "incidents_dat_incidents", ["incident_id"], name: "index_incidents_dat_incidents_on_incident_id", unique: true

  create_table "incidents_deployments", force: true do |t|
    t.integer   "person_id"
    t.string    "dr_name"
    t.string    "gap"
    t.string    "group"
    t.string    "activity"
    t.string    "position"
    t.string    "qual"
    t.date      "date_first_seen"
    t.date      "date_last_seen"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "incidents_dispatch_log_items", force: true do |t|
    t.integer   "dispatch_log_id"
    t.timestamp "action_at"
    t.string    "action_type"
    t.string    "recipient"
    t.string    "operator"
    t.string    "result"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_dispatch_log_items", ["dispatch_log_id"], name: "index_incidents_dispatch_log_items_on_dispatch_log_id"

  create_table "incidents_dispatch_logs", force: true do |t|
    t.string    "incident_number"
    t.integer   "chapter_id"
    t.integer   "incident_id"
    t.timestamp "received_at"
    t.timestamp "delivered_at"
    t.string    "delivered_to"
    t.string    "incident_type"
    t.string    "address"
    t.string    "cross_street"
    t.string    "county_name"
    t.string    "displaced"
    t.string    "services_requested"
    t.string    "agency"
    t.string    "contact_name"
    t.string    "contact_phone"
    t.string    "caller_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_dispatch_logs", ["chapter_id"], name: "index_incidents_dispatch_logs_on_chapter_id"
  add_index "incidents_dispatch_logs", ["incident_id"], name: "index_incidents_dispatch_logs_on_incident_id"

  create_table "incidents_event_logs", force: true do |t|
    t.integer   "incident_id"
    t.integer   "person_id"
    t.string    "event"
    t.timestamp "event_time"
    t.text      "message"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_event_logs", ["incident_id"], name: "index_incidents_event_logs_on_incident_id"
  add_index "incidents_event_logs", ["person_id"], name: "index_incidents_event_logs_on_person_id"

  create_table "incidents_incidents", force: true do |t|
    t.integer   "chapter_id"
    t.integer   "county_id"
    t.string    "incident_number"
    t.string    "incident_type"
    t.string    "cas_incident_number"
    t.date      "date"
    t.integer   "num_adults"
    t.integer   "num_children"
    t.integer   "num_families"
    t.integer   "num_cases"
    t.string    "incident_description"
    t.text      "narrative_brief"
    t.text      "narrative"
    t.string    "address"
    t.string    "cross_street"
    t.string    "neighborhood"
    t.string    "city"
    t.string    "state"
    t.string    "zip"
    t.decimal   "lat"
    t.decimal   "lng"
    t.string    "idat_incident_id"
    t.string    "idat_incident_rev"
    t.timestamp "last_idat_sync"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "last_no_incident_warning"
    t.boolean   "ignore_incident_report"
  end

  add_index "incidents_incidents", ["chapter_id"], name: "index_incidents_incidents_on_chapter_id"
  add_index "incidents_incidents", ["county_id"], name: "index_incidents_incidents_on_county_id"
  add_index "incidents_incidents", ["incident_number"], name: "index_incidents_incidents_on_incident_number", unique: true

  create_table "incidents_notification_subscriptions", force: true do |t|
    t.integer   "person_id"
    t.integer   "county_id"
    t.string    "notification_type"
    t.boolean   "persistent",        default: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_notification_subscriptions", ["county_id"], name: "index_incidents_notification_subscriptions_on_county_id"
  add_index "incidents_notification_subscriptions", ["person_id"], name: "index_incidents_notification_subscriptions_on_person_id"

  create_table "incidents_responder_assignments", force: true do |t|
    t.integer   "person_id"
    t.integer   "incident_id"
    t.string    "role"
    t.string    "response"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "was_flex",    default: false
  end

  add_index "incidents_responder_assignments", ["incident_id"], name: "index_incidents_responder_assignments_on_incident_id"
  add_index "incidents_responder_assignments", ["person_id"], name: "index_incidents_responder_assignments_on_person_id"

  create_table "incidents_vehicle_uses", force: true do |t|
    t.integer   "vehicle_id"
    t.integer   "incident_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "incidents_vehicle_uses", ["incident_id"], name: "index_incidents_vehicle_uses_on_incident_id"
  add_index "incidents_vehicle_uses", ["vehicle_id"], name: "index_incidents_vehicle_uses_on_vehicle_id"

  create_table "logistics_vehicles", force: true do |t|
    t.integer   "chapter_id"
    t.string    "name"
    t.string    "category"
    t.string    "address"
    t.string    "city"
    t.string    "state"
    t.string    "zip"
    t.decimal   "lat"
    t.decimal   "lng"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "motds", force: true do |t|
    t.integer   "chapter_id"
    t.timestamp "begins"
    t.timestamp "ends"
    t.string    "cookie_code"
    t.text      "html"
    t.string    "dialog_class"
    t.integer   "cookie_version"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "path_regex_raw"
  end

  add_index "motds", ["chapter_id"], name: "index_motds_on_chapter_id"

  create_table "roster_cell_carriers", force: true do |t|
    t.string    "name"
    t.string    "sms_gateway"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "roster_chapters", force: true do |t|
    t.string    "name"
    t.string    "code"
    t.string    "short_name"
    t.string    "time_zone_raw"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "roster_counties", force: true do |t|
    t.integer   "chapter_id"
    t.string    "name"
    t.string    "abbrev"
    t.string    "county_code"
    t.string    "fips_code"
    t.string    "gis_name"
    t.string    "vc_regex_raw"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "roster_county_memberships", force: true do |t|
    t.integer "county_id"
    t.integer "person_id"
    t.boolean "persistent"
  end

  create_table "roster_people", force: true do |t|
    t.integer   "chapter_id"
    t.integer   "primary_county_id"
    t.string    "first_name"
    t.string    "last_name"
    t.string    "email"
    t.string    "secondary_email"
    t.string    "username"
    t.string    "home_phone"
    t.string    "cell_phone"
    t.string    "work_phone"
    t.string    "alternate_phone"
    t.string    "sms_phone"
    t.string    "phone_1_preference"
    t.string    "phone_2_preference"
    t.string    "phone_3_preference"
    t.string    "phone_4_preference"
    t.string    "address1"
    t.string    "address2"
    t.string    "city"
    t.string    "state"
    t.string    "zip"
    t.integer   "vc_id"
    t.integer   "vc_member_number"
    t.integer   "home_phone_carrier_id"
    t.integer   "work_phone_carrier_id"
    t.integer   "cell_phone_carrier_id"
    t.integer   "alternate_phone_carrier_id"
    t.integer   "sms_phone_carrier_id"
    t.boolean   "home_phone_disable"
    t.boolean   "work_phone_disable"
    t.boolean   "cell_phone_disable"
    t.boolean   "alternate_phone_disable"
    t.boolean   "sms_phone_disable"
    t.string    "encrypted_password"
    t.string    "password_salt"
    t.binary    "persistence_token"
    t.timestamp "last_login"
    t.timestamp "vc_imported_at"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.decimal   "lat"
    t.decimal   "lng"
  end

  create_table "roster_position_memberships", force: true do |t|
    t.integer "position_id"
    t.integer "person_id"
    t.boolean "persistent"
  end

  create_table "roster_positions", force: true do |t|
    t.integer   "chapter_id"
    t.string    "name"
    t.string    "vc_regex_raw"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "hidden",         default: false
    t.string    "watchfire_role"
    t.string    "abbrev"
  end

  create_table "roster_positions_roles", id: false, force: true do |t|
    t.integer "position_id"
    t.integer "role_id"
  end

  create_table "roster_positions_scheduler_shifts", id: false, force: true do |t|
    t.integer "shift_id"
    t.integer "position_id"
  end

  create_table "roster_roles", force: true do |t|
    t.integer   "chapter_id"
    t.string    "name"
    t.string    "grant_name"
    t.text      "role_scope"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "scheduler_dispatch_configs", force: true do |t|
    t.integer   "county_id"
    t.integer   "backup_first_id"
    t.integer   "backup_second_id"
    t.integer   "backup_third_id"
    t.integer   "backup_fourth_id"
    t.boolean   "is_active"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "scheduler_dispatch_configs", ["backup_first_id"], name: "index_scheduler_dispatch_configs_on_backup_first_id"
  add_index "scheduler_dispatch_configs", ["backup_fourth_id"], name: "index_scheduler_dispatch_configs_on_backup_fourth_id"
  add_index "scheduler_dispatch_configs", ["backup_second_id"], name: "index_scheduler_dispatch_configs_on_backup_second_id"
  add_index "scheduler_dispatch_configs", ["backup_third_id"], name: "index_scheduler_dispatch_configs_on_backup_third_id"
  add_index "scheduler_dispatch_configs", ["county_id"], name: "index_scheduler_dispatch_configs_on_county_id"

  create_table "scheduler_dispatch_configs_admin_notifications", id: false, force: true do |t|
    t.integer "scheduler_dispatch_config_id"
    t.integer "roster_person_id"
  end

  create_table "scheduler_flex_schedules", force: true do |t|
    t.integer   "person_id"
    t.boolean   "available_sunday_day"
    t.boolean   "available_sunday_night"
    t.boolean   "available_monday_day"
    t.boolean   "available_monday_night"
    t.boolean   "available_tuesday_day"
    t.boolean   "available_tuesday_night"
    t.boolean   "available_wednesday_day"
    t.boolean   "available_wednesday_night"
    t.boolean   "available_thursday_day"
    t.boolean   "available_thursday_night"
    t.boolean   "available_friday_day"
    t.boolean   "available_friday_night"
    t.boolean   "available_saturday_day"
    t.boolean   "available_saturday_night"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "scheduler_flex_schedules", ["person_id"], name: "index_scheduler_flex_schedules_on_person_id"

  create_table "scheduler_notification_settings", force: true do |t|
    t.integer   "email_advance_hours"
    t.integer   "sms_advance_hours"
    t.integer   "sms_only_after",            default: 0
    t.integer   "sms_only_before",           default: 86400
    t.boolean   "send_email_invites"
    t.string    "calendar_api_token"
    t.text      "shift_notification_phones"
    t.boolean   "email_swap_requested"
    t.boolean   "email_all_swaps"
    t.boolean   "email_calendar_signups"
    t.integer   "email_all_shifts_at"
    t.integer   "sms_all_shifts_at"
    t.date      "last_all_shifts_email"
    t.date      "last_all_shifts_sms"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "email_all_swaps_daily"
  end

  create_table "scheduler_shift_assignments", force: true do |t|
    t.integer   "person_id"
    t.integer   "shift_id"
    t.date      "date"
    t.boolean   "email_invite_sent",   default: false
    t.boolean   "email_reminder_sent", default: false
    t.boolean   "sms_reminder_sent",   default: false
    t.boolean   "available_for_swap",  default: false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "scheduler_shift_assignments", ["person_id"], name: "index_scheduler_shift_assignments_on_person_id"
  add_index "scheduler_shift_assignments", ["shift_id"], name: "index_scheduler_shift_assignments_on_shift_id"

  create_table "scheduler_shift_groups", force: true do |t|
    t.string    "name"
    t.string    "period"
    t.integer   "start_offset"
    t.integer   "end_offset"
    t.integer   "chapter_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "scheduler_shift_groups", ["chapter_id"], name: "index_scheduler_shift_groups_on_chapter_id"

  create_table "scheduler_shifts", force: true do |t|
    t.string    "name"
    t.string    "abbrev"
    t.integer   "shift_group_id"
    t.integer   "max_signups"
    t.integer   "county_id"
    t.integer   "ordinal"
    t.integer   "spreadsheet_ordinal"
    t.integer   "dispatch_role"
    t.date      "shift_begins"
    t.date      "shift_ends"
    t.date      "signups_frozen_before"
    t.integer   "max_advance_signup"
    t.date      "signups_available_before"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "scheduler_shifts", ["county_id"], name: "index_scheduler_shifts_on_county_id"
  add_index "scheduler_shifts", ["shift_group_id"], name: "index_scheduler_shifts_on_shift_group_id"

end
