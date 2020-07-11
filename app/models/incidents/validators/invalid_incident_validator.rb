class Incidents::Validators::InvalidIncidentValidator < DelegatedValidator

  self.target_class = Incidents::Incident

  validates :reason_marked_invalid, :narrative, presence: true

end