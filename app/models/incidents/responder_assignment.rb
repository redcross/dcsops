class Incidents::ResponderAssignment < ActiveRecord::Base
  ROLES_TO_LABELS = {'team_lead' => 'Team Lead', 'trainee_lead' => 'Team Lead Trainee',
                     'responder' => 'Responder', 'public_affairs' => 'Public Affairs', 'health_services' => 'Health Services',
                     'mental_health' => 'Mental Health', 'dispatch' => 'Dispatch', 'activator' => 'Activator'}
  ROLES = ROLES_TO_LABELS.keys
  ON_SCENE_ROLES = %w(responder team_lead trainee_lead public_affairs health_services mental_health)
  RESPONSES = %w(not_available no_answer wrong_number no_longer_active)
  RESPONSES_TO_LABELS = RESPONSES.map{|x| {x => x.titleize}}.inject(:merge)

  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :incident, class_name: 'Incidents::Incident', foreign_key: 'incident_id', inverse_of: :responder_assignments

  validates_presence_of :person
  validates :role, presence: true, inclusion: {in: ROLES + RESPONSES, allow_blank: true}

  def humanized_role
    ROLES_TO_LABELS[role] || RESPONSES_TO_LABELS[role]
  end

  def self.grouped_roles
    [
      ["Did Not Respond", Incidents::ResponderAssignment::RESPONSES_TO_LABELS.invert.to_a],
      ["Respond To Incident", Incidents::ResponderAssignment::ROLES_TO_LABELS.invert.to_a.reject{|a| a.last == 'team_lead'}]
    ]
  end

  def was_available
    ROLES.include? role
  end

  def on_scene
    ON_SCENE_ROLES.include? role
  end

  scope :on_scene, -> { where{ role.in( ON_SCENE_ROLES ) } }
  scope :was_available, -> { where{ role.in( my{ROLES}) }}
  scope :with_person_in_counties, ->(counties){ joins{person.county_memberships}.where{person.county_memberships.county_id.in(my{Array(counties)}) } }
  scope :for_chapter, -> chapter { joins{incident}.where{incident.chapter_id==chapter} }
end
