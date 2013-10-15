class Incidents::Validators::CompleteReportValidator < DelegatedValidator

  self.target_class = Incidents::DatIncident

  validates :address, :city, :state, :zip, presence: true # :cross_street
  validates :incident_call_type, :incident_type, :structure_type, presence: true

  validates :units_affected, :units_minor, :units_major, :units_destroyed, presence: true, numericality: {:greater_than_or_equal_to => 0}
  validates :num_adults, :num_children, :num_families, presence: true, numericality: {:greater_than_or_equal_to => 0}
  validates :num_people_injured, :num_people_hospitalized, :num_people_deceased, presence: true, numericality: {:greater_than_or_equal_to => 0}

  validates :responder_notified, :responder_arrived, :responder_departed, presence: true
  validates_with Incidents::Validators::TimesInCorrectOrderValidator

  validates :completed_by, :vehicle_uses, presence: true

  validates_associated :incident

end