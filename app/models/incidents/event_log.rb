class Incidents::EventLog < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :event_logs
  belongs_to :person, class_name: 'Roster::Person'

  validates :event_time, :incident, presence: {allow_blank: false}
  validates :person, presence: {unless: ->(log){log.event =~ /(dispatch_|dat_)/}}
  validates :message, presence: {if: ->(log){log.event == 'note'}, allow_blank: false}
  validates :event, uniqueness: {scope: :incident_id, if: ->(log){!%w(note dispatch_note).include? log.event}}

  EVENT_TYPES = {
    "Note" => 'note',
    "Incident Occurred" => 'incident_occurred',
    "Assistance Requested" => 'assistance_requested',
    "ARC Dispatch Received Call" => 'dispatch_received',
    "ARC Dispatch" => 'dispatch_note',
    "ARC Dispatch Relayed Call" => 'dispatch_relayed',
    "DAT Received Call" => 'dat_received',
    "Incident Verified" => 'incident_verified',
    "DAT Picked Up Vehicle" => 'dat_vehicle_pickup',
    "DAT On Scene" => 'dat_on_scene',
    "DAT Departed Scene" => 'dat_departed_scene',
    "Incident Reopened" => 'incident_reopened',
    "Incident Closed" => 'incident_closed',
  }

  assignable_values_for :event do
    EVENT_TYPES.invert
  end
end