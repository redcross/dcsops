class Incidents::Incident < ActiveRecord::Base
  include HasDelegatedValidators
  include Incidents::IncidentPartners
  include Mappable

  has_paper_trail meta: {chapter_id: ->(inc){inc.chapter_id}}

  before_validation :set_incident_number, on: :create

  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :area, class_name: 'Roster::County'

  has_one :cas_incident, class_name: 'Incidents::CasIncident'
  has_one :dat_incident, class_name: 'Incidents::DatIncident', inverse_of: :incident
  has_one :dispatch_log, class_name: 'Incidents::DispatchLog'
  
  has_many :event_logs, ->{ order{event_time.desc} }, class_name: 'Incidents::EventLog', inverse_of: :incident
  #has_one :latest_event_log, ->{ order{event_time.desc}.where{event != 'note'} }, class_name: 'Incidents::EventLog'
  has_many :attachments, class_name: 'Incidents::Attachment', inverse_of: :incident
  has_many :cases, class_name: 'Incidents::Case', inverse_of: :incident

  has_many :responder_assignments, lambda { where{role != 'team_lead'}}, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id, inverse_of: :incident
  has_many :all_responder_assignments, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_many :on_scene_responder_assignments, lambda { on_scene }, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_one :team_lead, lambda{ where(role: 'team_lead')}, class_name: 'Incidents::ResponderAssignment', foreign_key: 'incident_id'

  accepts_nested_attributes_for :team_lead, update_only: true
  accepts_nested_attributes_for :responder_assignments, reject_if: -> hash {(hash[:person_id].blank?)}, allow_destroy: true
  accepts_nested_attributes_for :event_logs

  # We always want these to be present
  validates :chapter, :area, :date, presence: true
  validates :incident_number, presence: true, format: /\A\d{2}-\d{3,}\z/, uniqueness: { scope: :chapter_id }

  #validates_associated :responder_assignments

  #delegate :address,  :city, :state, :zip, :lat, :lng, :num_adults, :num_children, to: :dat_incident
  #delegate :units_affected, to: :dat_incident

  scope :for_chapter, -> chapter { where{chapter_id==chapter}}
  scope :in_area, -> area {where{area_id == area}}
  scope :incident_stats, lambda {
    valid.order(nil).select{[
      count(id).as(:incident_count),
      sum(num_cases).as(:case_count),
      sum(num_families).as(:family_count),
      sum(num_adults + num_children).as(:client_count)
    ]}.take
  }
  scope :valid, lambda {
    where{status != 'invalid'}
  }
  scope :with_status, -> filter_status {
    where{status == filter_status}
  }
  scope :needs_incident_report, lambda {
    with_status 'open'
  }
  scope :open_cases, lambda {
    valid.joins{cas_incident.cases.outer}.where{((cas_incident.cases_open > 0) | (cas_incident.last_date_with_open_cases >= 7.days.ago)) & (cas_incident.cases.case_last_updated > 2.months.ago)}
  }

  def self.count_resources scope, resources
    scope.joins{dat_incident}.unscope(:order).select do
      resources.map do |res|
        sum(coalesce(cast(dat_incident.resources.op('->', res).as(integer)), 0)).as(res)
      end
    end.take.attributes.slice(*resources)
  end

  assignable_values_for :incident_type, allow_blank: true do
    self.class.valid_incident_types + self.class.invalid_incident_types
  end

  assignable_values_for :status do
    %w(open closed invalid)
  end

  delegated_validator Incidents::Validators::IncidentValidator, if: :valid_incident?
  delegated_validator Incidents::Validators::InvalidIncidentValidator, if: :invalid_incident?

  def self.[] incident_number
    find_by incident_number: incident_number
  end

  def valid_incident?
    status == 'closed'
  end

  def invalid_incident?
    status == 'invalid'
  end

  def open_incident?
    status == 'open'
  end

  def self.valid_incident_types
    %w(fire flood police tornado blizzard storm transportation hazmat explosion search_and_rescue earthquake)
  end

  def humanized_valid_incident_types
    self.class.valid_incident_types.map{|t| AssignableValues::HumanizedValue.new(t, t.titleize)}
  end

  def self.invalid_incident_types
    %w(invalid duplicate not_eligible_for_services)
  end

  def humanized_invalid_incident_types
    self.class.invalid_incident_types.map{|t| AssignableValues::HumanizedValue.new(t, t.titleize)}
  end

  def ensure_unique_responders
    # Need this as the uniqueness validation doesn't take into account marked for deletion
    return unless team_lead and dat_incident

    ids = [team_lead.person_id]
    responder_assignments.select{|r| !r.marked_for_destruction?}.each do |assignment|
      if ids.include? assignment.person_id
        assignment.errors[:person_id] << 'is already taken'
        errors[:responder_assignments] << 'has duplicates'
      end
    end
  end

  def update_from_dat_incident
    address_fields = [:num_adults, :num_children, :num_families]
    if dat_incident
      address_fields.each do |f|
        self.send "#{f}=", dat_incident.send(f)
      end
    end
    save!
  end

  def update_from_cas
    if cas_incident
      update_attribute :num_cases, cas_incident.cases.count
    end
  end

  def to_param
    incident_number
  end

  def incident_status
    latest_event_log.try(:event)
  end
  
  def incident_status_title
    event = latest_event_log.try(:event)
    event && Incidents::EventLog::EVENTS_TO_DESCRIPTIONS[event]
  end

  def area_name
    area.try :name
  end

  def services_description
    services = dat_incident.try(:services) and services.map(&:titleize).to_sentence
  end

  def to_label
    [incident_number, county.try(:name), date.to_s, incident_type, address].compact.join " "
  end

  def time_to_on_scene
    received = self.event_logs.where{event.in(['dispatch_received', 'dispatch_note', 'dat_received'])}.order{event_time}.first
    on_scene = self.event_logs.where{event.in(['dat_on_scene'])}.first

    if received and on_scene
      on_scene.event_time - received.event_time
    end
  end

  def link_to_cas_incident(cas)
    raise "Already have a CAS Incident" if cas_incident.present?
    raise "CAS Incident is already linked" if cas.incident.present?


    self.class.transaction do 
      self.cas_incident_number = cas.cas_incident_number
      cas.incident = self
      self.save!
      cas.save!
    end
  end

  def timeline_collect_keys
    chapter.try(:incidents_timeline_collect_array, Incidents::TimelineProxy::EVENT_TYPES) || []
  end

  def timeline_mandatory_keys
    chapter.try(:incidents_timeline_mandatory_array, Incidents::TimelineProxy::EVENT_TYPES) || []
  end

  def full_address
    [[address, city, state].compact.join(", "), zip].compact.join "  "
  end

  def latest_event_log
    event_logs.detect{|l| !%w(note dispatch_note).include?(l.event)}
  end

  def timeline
    @timeline ||= Incidents::TimelineProxy.new(self, timeline_mandatory_keys)
  end

  def timeline_attributes=(attrs)
    timeline.attributes = attrs
  end

  def set_incident_number
    if chapter.incidents_sequence_enabled
      seq = Incidents::IncidentNumberSequence.new(chapter)
      self.incident_number = seq.next_sequence!
    end
    true
  end

  def take_location_from geocode
    return unless geocode.success?
    self.lat = geocode.lat
    self.lng = geocode.lng
    self.city = geocode.city
    self.county = geocode.district.try(:gsub, ' County', '')
  end

end
