class Incidents::Validators::IncidentValidator < DelegatedValidator

  self.target_class = Incidents::Incident

  validates :incident_type, :narrative, presence: true
  validates_associated :team_lead, if: ->(inc) {inc.valid_incident?}, allow_nil: false
  validates_associated :responder_assignments, if: ->(inc) {inc.valid_incident?}, allow_nil: false
  validate :ensure_unique_responders
  validates :address, :city, :state, :zip, presence: true
  validates_associated :timeline

  def ensure_unique_responders
    # Need this as the uniqueness validation doesn't take into account marked for deletion
    return unless team_lead and dat_incident

    ids = [team_lead.person_id]
    responder_assignments.select{|r| !r.marked_for_destruction?}.each do |assignment|
      if ids.include? assignment.person_id
        assignment.errors[:person_id] << 'is already taken'
        errors[:responder_assignments] << 'has duplicates'
      end
      ids << assignment.person_id
    end
  end

end