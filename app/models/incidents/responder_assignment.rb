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
  validates :person_id, uniqueness: {scope: :incident_id}
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
  scope :with_person_in_shift_territories, ->(shift_territories){ joins{person.shift_territory_memberships}.where{person.shift_territory_memberships.shift_territory_id.in(my{Array(shift_territories)}) } }
  scope :for_region, -> region { joins{incident}.where{incident.region_id==region} }
  def self.open
    was_available
  end
  def self.for_person person
    where{person_id == person}
  end
  def self.for_incident inc
    where{incident_id == inc}
  end
  def self.driving_distance
    on_scene.pluck(:driving_distance).flatten.select(&:present?).map{|dist| [50, dist * 2].min}.sum.round
  end

  def dispatched!(user=nil)
    update_attribute :dispatched_at, incident.region.time_zone.now unless dispatched_at
  end

  def on_scene!(user=nil)
    update_attribute :on_scene_at, incident.region.time_zone.now unless on_scene_at

    create_event_unless_exists 'dat_on_scene', incident.region.time_zone.now, "#{person.full_name} arrived on scene.  (Automatic message)", user
  end

  def departed_scene!(user=nil)
    update_attribute :departed_scene_at, incident.region.time_zone.now unless departed_scene_at

    responders_still_on_scene = incident.all_responder_assignments.where{departed_scene_at == nil}.on_scene.exists?
    if !responders_still_on_scene
     create_event_unless_exists('dat_departed_scene', incident.region.time_zone.now, "#{person.full_name} was the last to depart the scene.  (Automatic message)", user)
    end
  end

  def create_event_unless_exists event, time, message, user
    unless incident.event_logs.where(event: event).exists?
      incident.event_logs.create!(event: event, event_time: time, message: message, person: user)
    end
  end
end
