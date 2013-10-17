class Incidents::Validators::InvalidIncidentValidator < DelegatedValidator

  self.target_class = Incidents::Incident

  validates :incident_type, :narrative, presence: true
  validates_associated :team_lead, if: ->(inc) {inc.dat_incident}, allow_nil: false

end