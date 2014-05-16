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
  validates :role, presence: true, inclusion: {in: ROLES + RESPONSES, allow_blank: true}, uniqueness: {scope: :incident_id, if: ->(obj){obj.role == 'team_lead'}}

  def humanized_role
    ROLES_TO_LABELS[role] || RESPONSES_TO_LABELS[role]
  end

  def self.grouped_roles(team_lead=false)
    [
      ["Did Not Respond", Incidents::ResponderAssignment::RESPONSES_TO_LABELS.invert.to_a],
      ["Responded To Incident", Incidents::ResponderAssignment::ROLES_TO_LABELS.invert.to_a.reject{|a| !team_lead && a.last == 'team_lead'}]
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
  def self.open
    was_available
  end
  def self.for_person person
    where{person_id == person}
  end

  def on_scene!(user=nil)
    update_attribute :on_scene_at, incident.chapter.time_zone.now unless on_scene_at

    on_scene = incident.event_logs.where{event == 'dat_on_scene'}.exists?
    unless on_scene
      incident.event_logs.create!(event: 'dat_on_scene', event_time: incident.chapter.time_zone.now, message: "#{person.full_name} arrived on scene.  (Automatic message)", person: user)
    end
  end

  def departed_scene!(user=nil)
    update_attribute :departed_scene_at, incident.chapter.time_zone.now unless departed_scene_at

    responders_still_on_scene = incident.all_responder_assignments.where{departed_scene_at == nil}.select(&:on_scene).present?
    departed_scene_exists = incident.event_logs.where{event == 'dat_departed_scene'}.exists?
    if !responders_still_on_scene && !departed_scene_exists
      incident.event_logs.create!(event: 'dat_departed_scene', event_time: incident.chapter.time_zone.now, message: "#{person.full_name} was the last to depart the scene.  (Automatic message)", person: user)
    end
  end
end
