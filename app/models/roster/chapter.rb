class Roster::Chapter < ActiveRecord::Base
  include SerializedColumns
  has_many :counties
  has_many :positions
  has_many :people
  has_many :roles

  def time_zone
    @_tz ||= ActiveSupport::TimeZone[self.time_zone_raw]
  end

  serialized_accessor :config, :incidents_map_center_lat, :decimal
  serialized_accessor :config, :incidents_map_center_lng, :decimal
  serialized_accessor :config, :incidents_map_zoom, :integer
  serialized_accessor :config, :incidents_map_framing_points, :string
  serialized_accessor :config, :incidents_geocode_bounds, :string
  serialized_accessor :config, :incidents_resources_tracked, :string
  serialized_accessor :config, :incidents_report_editable, :boolean
  serialized_accessor :config, :incidents_collect_case_details, :boolean
  serialized_accessor :config, :incidents_enable_dispatch_console, :boolean
  serialized_accessor :config, :incidents_dispatch_console_ignore_county, :boolean
  serialized_accessor :config, :idat_database, :string
  serialized_accessor :config, :incidents_report_dro_ignore, :string
  serialized_accessor :config, :cas_chapter_codes, :string
  serialized_accessor :config, :incidents_timeline_collect, :string
  serialized_accessor :config, :incidents_timeline_collect_source, :string
  serialized_accessor :config, :incidents_timeline_mandatory, :string
  serialized_accessor :config, :incidents_sequence_year, :integer
  serialized_accessor :config, :incidents_sequence_number, :integer
  serialized_accessor :config, :incidents_sequence_format, :string
  serialized_accessor :config, :incidents_sequence_enabled, :boolean
  serialized_accessor :config, :incidents_enabled_report_frequencies, :string
  serialized_accessor :config, :incidents_report_send_automatically, :boolean
  serialized_accessor :config, :incidents_report_send_at, :integer, default: 0
  serialized_accessor :config, :incidents_report_include_assistance_amounts, :boolean
  serialized_accessor :config, :incidents_report_use_response_date, :boolean
  serialized_accessor :config, :incidents_capture_more_details_on_create, :boolean
  serialized_accessor :config, :incidents_response_date_cutoff, :integer, default: 0
  serialized_accessor :config, :incidents_timeline_collect_source, :string
  serialized_accessor :config, :incidents_report_advanced_details, :boolean
  serialized_accessor :config, :incidents_use_escalation_levels, :boolean

  serialized_accessor :config, :scheduler_flex_day_start, :integer
  serialized_accessor :config, :scheduler_flex_night_start, :integer

  serialized_accessor :config, :salesforce_sso_url, :string

  serialized_accessor :config, :cas_host, :string

  serialized_accessor :config, :kiosk_show_counties, :string

  serialized_accessor :config, :twilio_account_sid, :string
  serialized_accessor :config, :twilio_auth_token, :string
  serialized_accessor :config, :incidents_twilio_number, :string
  serialized_accessor :config, :incidents_enable_messaging, :boolean
  serialized_accessor :config, :incidents_enable_chat, :boolean

  def self.array_accessor *syms
    syms.each do |sym|
      define_method "#{sym}_array" do |valid_options=nil|
        val = self.send(sym) || ''
        array = val.split(',').select(&:present?)
        array = (array & valid_options) if valid_options
        array
      end
    end
  end

  array_accessor :cas_chapter_codes
  array_accessor :incidents_timeline_collect, :incidents_timeline_mandatory, :incidents_timeline_collect_source
  array_accessor :incidents_resources_tracked, :incidents_enabled_report_frequencies
  array_accessor :incidents_report_dro_ignore
end
