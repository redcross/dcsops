class Incidents::ResponderRecruitment < ApplicationRecord
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :outbound_message, class_name: 'Incidents::ResponderMessage'
  belongs_to :inbound_message, class_name: 'Incidents::ResponderMessage'

  def self.for_incident(incident); where{incident_id == incident}; end
  def self.open; joins{incident}.where{incident.status == 'open'}; end
  def self.for_person(person); where{person_id == person}; end

  def build_outbound_message(attrs)
    super(attrs).tap{|obj|
      obj.person = person
      obj.incident = incident
    }
  end

  assignable_values_for :response, allow_blank: true do
    %w(available unavailable)
  end

  def unavailable?; response == 'unavailable'; end
  def available?; response == 'available'; end

  def available!
    update_attributes response: 'available'
    assignment.delete_all
  end

  def unavailable!
    update_attributes response: 'unavailable'
    assignment.first_or_initialize.update_attributes role: 'not_available'
  end

  protected

  def assignment
    Incidents::ResponderAssignment.for_person(person_id).for_incident(incident_id)
  end
end
