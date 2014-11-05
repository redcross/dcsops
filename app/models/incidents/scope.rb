class Incidents::Scope < ActiveRecord::Base
  include Core::SerializedColumns
  include Core::ArrayAccessor
  belongs_to :chapter, class_name: "Roster::Chapter"
  has_and_belongs_to_many :chapters, class_name: "Roster::Chapter"
  has_many :report_subscriptions, class_name: 'Incidents::ReportSubscription'

  def self.for_chapter chapter
    where{chapter_id == chapter}.first!
  end

  def self.including_chapter chapter_ids
    joins{chapters}.where{chapters.id.in chapter_ids}
  end

  def incidents
    chapters = chapter_ids.blank? ? [chapter_id] : chapter_ids
    Incidents::Incident.for_chapter(chapters)
  end

  def to_param
    url_slug
  end

  def editable?
    chapter_ids.blank?
  end

  serialized_accessor :config, :incidents_map_center_lat, :decimal
  serialized_accessor :config, :incidents_map_center_lng, :decimal
  serialized_accessor :config, :incidents_map_zoom, :integer
  serialized_accessor :config, :summary_show_state, :boolean

  serialized_accessor :config, :boundary_polygon_filter, :string

  serialized_accessor :config, :report_frequencies, :string
  serialized_accessor :config, :report_send_automatically, :boolean
  serialized_accessor :config, :report_send_at, :integer, default: 0
  serialized_accessor :config, :report_include_assistance_amounts, :boolean
  serialized_accessor :config, :report_dro_ignore, :string
  serialized_accessor :config, :report_map_framing_points, :string
  serialized_accessor :config, :report_show_county_summary, :boolean

  serialized_accessor :config, :time_zone_raw, :string

  array_accessor :report_frequencies
  array_accessor :report_dro_ignore

  def time_zone
    @_tz ||= ActiveSupport::TimeZone[self.time_zone_raw]
  end

  def all_chapters
    chapter_id ? [chapter] : chapters
  end
end
