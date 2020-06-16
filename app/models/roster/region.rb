class Roster::Region < ApplicationRecord
  include Core::SerializedColumns
  include Core::ArrayAccessor
  has_many :shift_territories
  has_many :positions
  has_many :people
  has_many :capabilities

  has_one :vc_import_data

  has_many :incidents, class_name: "Incidents::Incident"
  has_many :event_logs, class_name: "Incidents::EventLog"
  has_many :call_logs, class_name: "Incidents::CallLog"
  has_many :cas_incidents, class_name: "Incidents::CasIncident"
  belongs_to :incident_number_sequence, class_name: "Incidents::NumberSequence"

  validates :url_slug, presence: true

  def time_zone
    @_tz ||= ActiveSupport::TimeZone[self.time_zone_raw]
  end

  def to_param
    url_slug || id
  end

  def self.find_by_slug slug
    where(url_slug: slug).first || find(slug)
  end

  serialized_accessor :config, :incidents_geocode_bounds, :string
  serialized_accessor :config, :incidents_resources_tracked, :string
  serialized_accessor :config, :incidents_report_editable, :boolean
  serialized_accessor :config, :incidents_collect_case_details, :boolean
  serialized_accessor :config, :incidents_enable_dispatch_console, :boolean
  serialized_accessor :config, :incidents_dispatch_console_ignore_shift_territory, :boolean
  serialized_accessor :config, :idat_database, :string
  serialized_accessor :config, :cas_region_codes, :string
  serialized_accessor :config, :incidents_timeline_collect, :string
  serialized_accessor :config, :incidents_timeline_collect_source, :string
  serialized_accessor :config, :incidents_timeline_mandatory, :string
  serialized_accessor :config, :incidents_report_include_assistance_amounts, :boolean
  serialized_accessor :config, :incidents_timeline_collect_source, :string
  serialized_accessor :config, :incidents_report_advanced_details, :boolean
  serialized_accessor :config, :incidents_use_escalation_levels, :boolean
  serialized_accessor :config, :incidents_use_global_log, :boolean
  serialized_accessor :config, :incidents_report_allow_manual_address, :boolean

  serialized_accessor :config, :salesforce_sso_url, :string

  serialized_accessor :config, :cas_host, :string
  serialized_accessor :config, :cas_username, :string
  serialized_accessor :config, :cas_password, :string

  serialized_accessor :config, :kiosk_show_shift_territories, :string

  serialized_accessor :config, :twilio_account_sid, :string
  serialized_accessor :config, :twilio_auth_token, :string
  serialized_accessor :config, :incidents_twilio_number, :string
  serialized_accessor :config, :incidents_enable_messaging, :boolean
  serialized_accessor :config, :incidents_delegate_region, :integer

  serialized_accessor :config, :incidents_notifications_reply_to, :string
  serialized_accessor :config, :incidents_notifications_custom_message, :string

  serialized_accessor :config, :scheduler_dispatch_export_recipient, :string
  serialized_accessor :config, :scheduler_flex_day_start, :integer
  serialized_accessor :config, :scheduler_flex_night_start, :integer
  serialized_accessor :config, :scheduler_submit_vc_hours, :boolean
  serialized_accessor :config, :scheduler_restrict_on_call_contacts, :boolean

  serialized_accessor :config, :roster_import_prospective_members, :boolean
  serialized_accessor :config, :directline_account_number, :string

  serialized_accessor :config, :division_name, :string
  serialized_accessor :config, :iir_emails, :string

  array_accessor :cas_region_codes
  array_accessor :incidents_timeline_collect, :incidents_timeline_mandatory, :incidents_timeline_collect_source
  array_accessor :incidents_resources_tracked
end
