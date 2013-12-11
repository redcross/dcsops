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
  serialized_accessor :config, :incidents_geocode_bounds, :string
  serialized_accessor :config, :incidents_resources_tracked, :string
  serialized_accessor :config, :incidents_report_editable, :boolean
  serialized_accessor :config, :incidents_collect_case_details, :boolean
  serialized_accessor :config, :incidents_enable_dispatch_console, :boolean
  serialized_accessor :config, :idat_database, :string
  serialized_accessor :config, :incidents_report_dro_ignore, :string
  serialized_accessor :config, :cas_chapter_codes, :string

  def incidents_resources_tracked_array
    self.incidents_resources_tracked.try(:split, ',')
  end

  def cas_chapter_code_array
    (self.cas_chapter_codes || '').split( ',').select(&:present?)
  end
end
