class Incidents::Validators::IncidentValidator < DelegatedValidator

  self.target_class = Incidents::Incident

  validates :incident_type, :narrative, presence: true
  validates_associated :team_lead, if: ->(inc) {inc.valid_incident?}, allow_nil: false
  validates_associated :responder_assignments, if: ->(inc) {inc.valid_incident?}, allow_nil: false
  validate :ensure_unique_responders
  validates :address, :city, :state, :zip, presence: true
  validates_associated :timeline

end