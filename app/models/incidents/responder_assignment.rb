class Incidents::ResponderAssignment < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :incident, class_name: 'Incidents::DatIncident', foreign_key: 'incident_id'

  validates_presence_of :person
  validates :role, presence: true, inclusion: {in: %w(recruited team_lead trainee_lead responder public_affairs health_services mental_health dispatch activator)}

  scope :on_scene, -> { where{ role.in( %w(responder team_lead health_services mental_health) ) } }
end
