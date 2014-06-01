class Incidents::Scope < ActiveRecord::Base
  include SerializedColumns
  belongs_to :chapter, class_name: "Roster::Chapter"
  has_and_belongs_to_many :chapters, class_name: "Roster::Chapter"

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

end
