class Incidents::ResponderMessage < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :responder_assignment, class_name: 'Incidents::ResponderAssignment'
  belongs_to :in_reply_to, class_name: 'Incidents::ResponderMessage'

  validates :region, :message, presence: true
  validates :person, presence: {if: ->msg{msg.direction != 'incoming'}}
  validates :message, length: {maximum: 1600}

  validate :validate_person_assigned_to_incident
  def validate_person_assigned_to_incident
    if direction == 'outgoing'
      assignments = incident.all_responder_assignments
      unless assignments.any?{|a| a.person_id == person_id}
        errors[:person_id] << "is not assigned to the incident"
      end
    end
  end

  validate :validate_person_has_sms_number
  def validate_person_has_sms_number
    if direction == 'outgoing' and person and person.sms_addresses.blank?
      errors[:person_id] << "does not have SMS messaging turned on"
    end
  end

  def self.unacknowledged_for_incident(incident)
    where{(incident_id == incident) & (acknowledged != true)}
  end
end
