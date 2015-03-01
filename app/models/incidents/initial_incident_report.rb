class Incidents::InitialIncidentReport < Incidents::DataModel
  belongs_to :completed_by, class_name: 'Roster::Person'
  belongs_to :approved_by, class_name: 'Roster::Person'

  with_options if: :approved_by do |approved|
    approved.validates :triggers, :expected_services, :trend, :estimated_units, :estimated_individuals, presence: true
    approved.validate :narrative_present, :timeline_entries_present
  end

  assignable_values_for :trend, allow_blank: true do
    %w(escalating stable deescalating ended)
  end

  def assignable_triggers
    %w(casualties staff_casualty facility_damage evacuation shelter media budget mutual_aid)
  end

  def assignable_services
    %w(shelter food health_services casework bulk_distribution mental_health_services none)
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
