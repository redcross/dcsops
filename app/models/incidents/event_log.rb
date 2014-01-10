class Incidents::EventLog < ActiveRecord::Base
  has_paper_trail meta: {root_type: 'Incidents::Incident', root_id: ->(obj){obj.incident_id}, chapter_id: ->(obj){obj.incident.chapter_id} }

  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :event_logs
  belongs_to :person, class_name: 'Roster::Person'

  validates :event_time, :incident, presence: {allow_blank: false, allow_nil: false}
  validates :person, presence: {unless: ->(log){log.event =~ /(dispatch_|dat_)/}}
  validates :message, presence: {if: ->(log){log.event == 'note'}, allow_blank: false}
  validates :event, uniqueness: {scope: :incident_id, if: ->(log){!%w(note dispatch_note).include? log.event}}

  EVENT_TYPES = {
    "note"=>"Note",
    "incident_occurred"=>     "Incident Occurred",
    "assistance_requested"=>  "Assistance Requested",
    "incident_verified"=>     "Incident Verified",
    "responders_identified"=> "Responders Identified"
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
end