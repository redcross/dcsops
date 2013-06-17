class Incidents::EventLog < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :person, class_name: 'Roster::Person'

  validates :event, :event_time, :incident, :person, presence: {allow_blank: false}
  validates :message, presence: {if: ->(log){log.event == 'note'}, allow_blank: false}
  validates :event, uniqueness: {scope: :incident_id, if: ->(log){log.event != 'note'}}

  EVENT_TYPES = {
    "Note" => 'note',
    "Incident Occurred" => 'incident_occurred',
    "Assistance Requested" => 'assistance_requested',
    "ARC Dispatch Received Call" => 'dispatch_received',
    "ARC Dispatch Relayed Call" => 'dispatch_relayed',
    "DAT Received Call" => 'dat_received',
    "Incident Verified" => 'incident_verified',
    "DAT Picked Up Vehicle" => 'dat_vehicle_pickup',
    "DAT On Scene" => 'dat_on_scene',
    "DAT Departed Scene" => 'dat_departed_scene',
    "Incident Reopened" => 'incident_reopened',
    "Incident Closed" => 'incident_closed',
  }

  EVENTS_TO_DESCRIPTIONS = EVENT_TYPES.invert
end