class Incidents::ResponderAssignment < ActiveRecord::Base
  ROLES_TO_LABELS = {'team_lead' => 'Team Lead', 'trainee_lead' => 'Trainee Lead',
                     'responder' => 'Responder', 'public_affairs' => 'Public Affairs', 'health_services' => 'Health Services',
                     'mental_health' => 'Mental Health', 'dispatch' => 'Dispatch', 'activator' => 'Activator'}
  ROLES = ROLES_TO_LABELS.keys
  RESPONSES = %w(not_available no_answer wrong_number no_longer_active)
  RESPONSES_TO_LABELS = RESPONSES.map{|x| {x => x.titleize}}.inject(:merge)

  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :incident, class_name: 'Incidents::Incident', foreign_key: 'incident_id', inverse_of: :responder_assignments

  validates_presence_of :person
  validates :role, presence: true, inclusion: {in: ROLES + RESPONSES, allow_blank: true}
  #validates :response, inclusion: {in: RESPONSES}
  #validates :person_id, uniqueness: {scope: :incident_id}

  def humanized_role
    ROLES_TO_LABELS[role] || RESPONSES_TO_LABELS[role]
  end

  def was_available
    ROLES.include? role
  end

  scope :on_scene, -> { where{ role.in( %w(responder team_lead health_services mental_health) ) } }

  
end
