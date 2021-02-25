class Incidents::InitialIncidentReport < Incidents::DataModel
  belongs_to :completed_by, class_name: 'Roster::Person'
  belongs_to :approved_by, class_name: 'Roster::Person'

  with_options if: :approved_by do |approved|
    approved.validates :triggers, :expected_services, :trend, :estimated_units, :estimated_individuals, presence: true
    approved.validate :narrative_present, :timeline_entries_present
  end

  assignable_values_for :trend, allow_blank: true do
    %w(escalating stable deescalating ended unknown)
  end

  assignable_values_for :significant_media do
    %w(local national no unknown)
  end

  assignable_values_for :safety_concerns do
    %w(yes no unknown)
  end

  assignable_values_for :weather_concerns do
    %w(yes no unknown)
  end

  assignable_values_for :disaster_type do
    [
      "bdc", # Building Collapse
      "bli", # Blizzard: Snow, Hail, Ice Storm
      "cdb", # Civil Disturbance
      "drt", # Drought
      "epd", # Epidemic
      "eqk", # Earthquake
      "exe", # Exercise
      "exp", # Explosion
      "fld", # Flood: Flash, Dam Break, Land/Mudslide
      "flt", #  Flood and Tornado
      "for", # Forest Fire: Wild/Range/Grass
      "haz", # Hazardous Material/Chemical Spill
      "hfl", # Hurricane Flood
      "hmf", # Hotel or Motel Fire
      "hur", # Hurricane, Tropical storm, Typhoon
      "icf", # Industrial or Commercial Fire
      "mff", # Multi-Family Fire
      "nui", # Nuclear Incident
      "ost", # Other Storm: Wind, Dust, Electrical, Rain
      "oth", # Other
      "ref", # Refugee Operation
      "sff", # Single Family Fire
      "srs", # Search and Rescue
      "tor", # Tornado/Cyclone
      "tra", # Transportation Incident
      "tsu", # Tsunami/Wave
      "ukn", # Unknown
      "vol", # Volcano
    ]
  end

  def assignable_triggers
    %w(casualties staff_casualty facility_damage evacuation shelter media budget mutual_aid eoc_activated significant_injuries)
  end

  def assignable_services
    %w(shelter food health_services casework bulk_distribution mental_health_services spiritual_care none)
  end

  def triggers= vals
    write_attribute :triggers, Array(vals).select(&:present?)
  end

  def expected_services= vals
    vals = Array(vals).select(&:present?)
    without_none = if vals.size >= 2 then vals.reject{|s| s == "none"} else vals end
    write_attribute :expected_services, without_none
  end

  def narrative_present
    unless incident.narrative.present?
      errors.add(:base, "Incident narrative time can't be blank")
    end
  end

  def timeline_entries_present
    timeline = incident.event_logs
    unless timeline.detect{|e| e.event == 'incident_occurred'}
      errors.add(:base, "Incident occured time can't be blank")
    end
    unless timeline.detect{|e| e.event == 'dat_received'} || timeline.detect{|e| e.event == 'dispatch_received'}
      errors.add(:base, "ARC Notified time can't be blank")
    end
  end
end
