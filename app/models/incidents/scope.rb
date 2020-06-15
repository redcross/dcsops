class Incidents::Scope < ApplicationRecord
  include Core::SerializedColumns
  include Core::ArrayAccessor
  belongs_to :region, class_name: "Roster::Region"
  has_and_belongs_to_many :regions, class_name: "Roster::Region"
  has_many :report_subscriptions, class_name: 'Incidents::ReportSubscription'

  def self.for_region region
    where(region: region).first!
  end

  def self.including_region region_ids
    joins(:regions).where{regions.id.in region_ids}
  end

  def incidents
    regions = region_ids.blank? ? [region_id] : region_ids
    Incidents::Incident.for_region(regions)
  end

  def to_param
    url_slug
  end

  def editable?
    region_ids.blank?
  end

  serialized_accessor :config, :incidents_map_center_lat, :decimal
  serialized_accessor :config, :incidents_map_center_lng, :decimal
  serialized_accessor :config, :incidents_map_zoom, :integer
  serialized_accessor :config, :summary_show_state, :boolean

  serialized_accessor :config, :boundary_kmz_location, :string

  serialized_accessor :config, :report_frequencies, :string
  serialized_accessor :config, :report_send_automatically, :boolean
  serialized_accessor :config, :report_send_at, :integer, default: 0
  serialized_accessor :config, :report_include_assistance_amounts, :boolean
  serialized_accessor :config, :report_dro_ignore, :string
  serialized_accessor :config, :report_map_framing_points, :string
  serialized_accessor :config, :report_show_shift_territory_summary, :boolean
  serialized_accessor :config, :enable_dispatch_console, :boolean

  serialized_accessor :config, :time_zone_raw, :string

  array_accessor :report_frequencies
  array_accessor :report_dro_ignore

  def time_zone
    @_tz ||= ActiveSupport::TimeZone[self.time_zone_raw]
  end

  def all_regions
    region_id ? [region] : regions
  end

  def call_logs
    Incidents::CallLog.all
  end
end
