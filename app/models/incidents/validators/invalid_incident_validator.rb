class Incidents::Validators::InvalidIncidentValidator < DelegatedValidator

  self.target_class = Incidents::Incident

  validates :incident_type, :narrative, presence: true

end