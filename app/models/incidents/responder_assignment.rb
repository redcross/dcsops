class Incidents::ResponderAssignment < ActiveRecord::Base
  ROLES_TO_LABELS = {'recruited' => 'Recruited', 'team_lead' => 'Team Lead', 'trainee_lead' => 'Trainee Lead',
                     'responder' => 'Responder', 'public_affairs' => 'Public Affairs', 'health_services' => 'Health Services',
                     'mental_health' => 'Mental Health', 'dispatch' => 'Dispatch', 'activator' => 'Activator'}
  ROLES = ROLES_TO_LABELS.keys
  RESPONSES = %w(available not_available no_answer wrong_number no_longer_active)
  RESPONSES_TO_LABELS = RESPONSES.map{|x| {x => x.titleize}}.inject(:merge)

  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :incident, class_name: 'Incidents::Incident', foreign_key: 'incident_id'

  validates_presence_of :person
  validates :role, presence: true, inclusion: {in: ROLES}
  validates :response, inclusion: {in: RESPONSES}
  validates :person_id, uniqueness: {scope: :incident_id}

  scope :on_scene, -> { where{ role.in( %w(responder team_lead health_services mental_health) ) } }

  
end
