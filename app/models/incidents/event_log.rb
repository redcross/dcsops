class Incidents::EventLog < Incidents::DataModel
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :region, class_name: 'Roster::Region'

  validates :event_time, presence: {allow_blank: false, allow_nil: false}
  validates :person, presence: {if: :body_required?}
  validates :message, presence: {if: :body_required?, allow_blank: false}
  validates :event, uniqueness: {scope: :incident_id, if: ->(log){log.incident_id && !%w(note dispatch_note).include?(log.event)}}

  def self.note
    where(event: 'note')
  end

  def self.for_type type
    where(event: type)
  end

  INCIDENT_EVENT_TYPES = {
    "note"=>"Note",
    "incident_occurred"=>     "Incident Occurred",
    "incident_notified"=>     "Notification of Incident",
#    "assistance_requested"=>  "Assistance Requested",
    "incident_verified"=>     "Incident Verified",
    "responders_identified"=> "Responders Identified",
    "dispatch_received"=>     "Assistance Requested",
    "dispatch_note"=>         "ARC Dispatch",
    "dispatch_relayed"=>      "Incident Dispatched",
    "dat_received"=>          "DAT Received Call",
    "dat_vehicle_pickup"=>    "DAT Picked Up Vehicle",
    "dat_on_scene"=>          "DAT On Scene",
    "dat_departed_scene"=>    "DAT Departed Scene"
  }

  GLOBAL_EVENT_TYPES = [
    'note',
    'vehicle_checkout',
    'radio_check',
    'call_incoming',
    'call_outgoing',
    'shift_change',
    'staff_reported_late',
    'staff_reported_sick'
  ]

  assignable_values_for :event do
    if has_incident?
      INCIDENT_EVENT_TYPES.keys
    else
      GLOBAL_EVENT_TYPES
    end
  end

  belongs_to :source, class_name: 'Lookup'
  validates :source, presence: {if: :source_required?}
  assignable_values_for :source, allow_blank: true do
    Lookup.for_region_and_scope(incident.try(:region_id), 'Incidents::EventLog#source')
  end

  def source_required?
    region = incident && incident.region
    region && region.incidents_timeline_collect_source_array.include?(event)
  end

  def body_required?
    !has_incident? || event == 'note'
  end

  def has_incident?
    incident_id || incident
  end

  def humanized_event
    INCIDENT_EVENT_TYPES[event]
  end

  def humanized_events
    INCIDENT_EVENT_TYPES.keys.map{|e| AssignableValues::HumanizedValue.new(e, INCIDENT_EVENT_TYPES[e])}
  end

  def event_time= new_time
    time = case new_time
    when String then Timeliness.parse(new_time)
    else new_time
    end

    super(time)
  rescue ArgumentError => e
    super(new_time)
  end

end

