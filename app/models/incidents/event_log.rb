class Incidents::EventLog < ActiveRecord::Base
  has_paper_trail meta: {root_type: 'Incidents::Incident', root_id: ->(obj){obj.incident_id}, chapter_id: ->(obj){obj.incident.chapter_id} }

  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :event_logs
  belongs_to :person, class_name: 'Roster::Person'

  validates :event_time, :incident, presence: {allow_blank: false, allow_nil: false}
  validates :person, presence: {if: :is_note?}
  validates :message, presence: {if: :is_note?, allow_blank: false}
  validates :event, uniqueness: {scope: :incident_id, if: ->(log){!%w(note dispatch_note).include? log.event}}

  EVENT_TYPES = {
    "note"=>"Note",
    "incident_occurred"=>     "Incident Occurred",
    "assistance_requested"=>  "Assistance Requested",
    "incident_verified"=>     "Incident Verified",
    "responders_identified"=> "Responders Identified",
    "dispatch_received"=>     "ARC Dispatch Received Call",
    "dispatch_note"=>         "ARC Dispatch",
    "dispatch_relayed"=>      "Incident Dispatched",
    "dat_received"=>          "DAT Received Call",
    "dat_vehicle_pickup"=>    "DAT Picked Up Vehicle",
    "dat_on_scene"=>          "DAT On Scene",
    "dat_departed_scene"=>    "DAT Departed Scene",
    "incident_closed"=>       "Incident Closed",
    "incident_reopened"=>     "Incident Reopened"
  }

  assignable_values_for :event do
    EVENT_TYPES
  end

  belongs_to :source, class_name: 'Lookup'
  validates :source, presence: {if: :source_required?}
  assignable_values_for :source, allow_blank: true do
    Lookup.for_chapter_and_scope(incident.try(:chapter_id), 'Incidents::EventLog#source')
  end

  def source_required?
    chapter = incident && incident.chapter
    chapter && chapter.incidents_timeline_collect_source_array.include?(event)
  end

  def is_note?
    event == 'note'
  end
end

