class Incidents::DatIncident < ActiveRecord::Base
  include HasDelegatedValidators
  has_paper_trail

  belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: :dat_incident
  belongs_to :completed_by, class_name: 'Roster::Person'
  has_many :vehicle_uses, class_name: 'Incidents::VehicleUse', foreign_key: 'incident_id'
  has_many :vehicles, through: :vehicle_uses, class_name: 'Logistics::Vehicle'

  TRACKED_RESOURCE_TYPES = %w(comfort_kits blankets pre_packs toys)

  # We put allow_blank: true here so that the delegated validator can decide if it can be blank
  assignable_values_for :incident_call_type, allow_blank: true do
    %w(hot cold)
  end

  assignable_values_for :structure_type, allow_blank: true do
    %w(single_family_home apartment sro mobile_home commercial none)
  end

  delegated_validator Incidents::Validators::CompleteReportValidator, if: :complete_report?

  accepts_nested_attributes_for :incident, update_only: true#, reject_if: :cant_update_incident

  serialize :services
  serialize :languages

  after_save :update_incident

  include SerializedColumns
  TRACKED_RESOURCE_TYPES.each do |type_s|
    type = type_s.to_sym
    serialized_accessor :resources, type, :integer
  end
  def resource_types_to_track
    TRACKED_RESOURCE_TYPES & (incident.try(:chapter).try(:incidents_resources_tracked_array) || [])
  end

  [:responder_notified=, :responder_arrived=, :responder_departed=].each do |sym|
    define_method sym do |val|
      if val.is_a? String
        super Chronic.parse(val)
      else
        super(val)
      end
    end
  end

  def update_incident
    if incident(true)
      incident.update_from_dat_incident
      update_timeline
    end
  end

  def complete_report?
    incident.try(:valid_incident?)
  end

  [:responder_notified, :responder_arrived, :responder_departed].each do |field|
    define_method :"#{field}=" do |val|
      if val.is_a? String
        time = nil
        begin
          time = Time.zone.parse(val)
        rescue ArgumentError
          errors[field] << "Invalid time format for #{field.to_s.titleize}: #{val}."
        end
        super(time)
      else
        super(val)
      end
    end
  end

  def update_timeline
    {'dat_received' => :responder_notified, 'dat_on_scene' => :responder_arrived, 'dat_departed_scene' => :responder_departed}.each do |event, attr|
      val = self.send(attr)
      if val
        incident.event_logs.where(event: event).first_or_initialize.update_attributes event_time: val
      end
    end
  end

  def units_total
    [units_affected, units_minor, units_major, units_destroyed].compact.sum
  end

  def cant_update_incident
    !(incident.nil? || incident.new_record?)
  end

  def languages= list
    list = list.select(&:present?) if list
    super(list)
  end

end
