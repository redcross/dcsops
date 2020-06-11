class Incidents::DatIncident < Incidents::DataModel
  include HasDelegatedValidators

  belongs_to :completed_by, class_name: 'Roster::Person'
  has_many :vehicle_uses, class_name: 'Incidents::VehicleUse', foreign_key: 'incident_id'
  has_many :vehicles, through: :vehicle_uses, class_name: 'Logistics::Vehicle', autosave: false

  TRACKED_RESOURCE_TYPES = %w(comfort_kits blankets pre_packs toys hydration snacks cleanup_kits flood_cleanup_kits cots)

  # We put allow_blank: true here so that the delegated validator can decide if it can be blank
  assignable_values_for :incident_call_type, allow_blank: true do
    %w(hot cold)
  end

  assignable_values_for :structure_type, allow_blank: true do
    %w(single_family_home apartment sro mobile_home commercial none)
  end

  assignable_values_for :vacate_type, allow_blank: true do
    Lookup.for_region_and_scope(incident.region, "Incidents::Incident#vacate_type").map{|l| {l.name => l.value}}.reduce(&:merge)
  end

  delegated_validator Incidents::Validators::CompleteReportValidator, if: :complete_report?

  accepts_nested_attributes_for :incident, update_only: true#, reject_if: :cant_update_incident

  serialize :services
  serialize :languages

  before_validation :cleanup_first_responders
  before_validation :cleanup_services

  include Core::SerializedColumns
  TRACKED_RESOURCE_TYPES.each do |type_s|
    type = type_s.to_sym
    serialized_accessor :resources, type, :integer
    validates type, numericality: {allow_nil: true, only_integer: true}
  end

  def resource_types_to_track
    TRACKED_RESOURCE_TYPES & (incident.try(:region).try(:incidents_resources_tracked_array) || [])
  end

  def complete_report?
    incident.try(:valid_incident?)
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

  def services= list
    list = list.select(&:present?) if list
    super(list)
  end

  def cleanup_first_responders
    unless services.try(:include?, 'canteened_responders')
      self.num_first_responders = nil
    end
  end

  def cleanup_services
    if services.present?
      without_none = services.reject{|v| v=='none'}
      if without_none.present?
        self.services = without_none
      end
    end
  end

end
