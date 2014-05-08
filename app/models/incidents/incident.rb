class Incidents::Incident < ActiveRecord::Base
  include HasDelegatedValidators
  include Incidents::IncidentPartners
  include Mappable

  has_paper_trail meta: {chapter_id: ->(inc){inc.chapter_id}}

  before_validation :set_incident_number, on: :create

  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :area, class_name: 'Roster::County'

  belongs_to :cas_incident, class_name: 'Incidents::CasIncident', primary_key: 'cas_incident_number', foreign_key: 'cas_incident_number'
  has_one :dat_incident, class_name: 'Incidents::DatIncident', inverse_of: :incident
  has_one :dispatch_log, class_name: 'Incidents::DispatchLog'
  
  has_many :event_logs, ->{ order{event_time.desc} }, class_name: 'Incidents::EventLog', inverse_of: :incident
  has_many :attachments, class_name: 'Incidents::Attachment', inverse_of: :incident
  has_many :cases, class_name: 'Incidents::Case', inverse_of: :incident

  has_many :responder_assignments, lambda { where{role != 'team_lead'}}, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id, inverse_of: :incident
  has_many :all_responder_assignments, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_one :team_lead, lambda{ where(role: 'team_lead')}, class_name: 'Incidents::ResponderAssignment', foreign_key: 'incident_id'

  accepts_nested_attributes_for :team_lead, update_only: true
  accepts_nested_attributes_for :responder_assignments, reject_if: -> hash {(hash[:person_id].blank?)}, allow_destroy: true
  accepts_nested_attributes_for :event_logs

  # We always want these to be present
  validates :chapter, :area, :date, presence: true
  validates :incident_number, presence: true, format: /\A\d{2}-\d{3,}\z/, uniqueness: { scope: :chapter_id }

  scope :for_chapter, -> chapter { where{chapter_id==chapter}}
  scope :in_area, -> area {where{area_id == area}}
  scope :valid, lambda {
    where{status != 'invalid'}
  }
  scope :with_status, -> filter_status {
    where{status == filter_status}
  }
  scope :needs_incident_report, lambda {
    with_status 'open'
  }
  scope :without_cas, -> {
    joins{cas_incident.outer}.where{(cas_incident.id == nil)}
  }
  scope :with_date_in, -> date_range {
    where{date.in(date_range)}
  }
  scope :with_county_name, -> name {
    where{county == name}
  }

  def self.incident_stats
    valid.order(nil).select{[
      count(id).as(:incident_count),
      sum(num_cases).as(:case_count),
      sum(num_families).as(:family_count),
      sum(num_adults + num_children).as(:client_count)
    ]}.take
  end

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
    %w(fire flood police vacate tornado blizzard storm transportation hazmat explosion search_and_rescue earthquake building_collapse)
  end

  def humanized_valid_incident_types
    self.class.valid_incident_types.map{|t| AssignableValues::HumanizedValue.new(t, t.titleize)}
  end

  def self.invalid_incident_types
    %w(invalid duplicate not_eligible_for_services no_response_needed)
  end

  def humanized_invalid_incident_types
    self.class.invalid_incident_types.map{|t| AssignableValues::HumanizedValue.new(t, t.titleize)}
  end

  def update_from_cas
    if cas_incident
      update_attribute :num_cases, cas_incident.cases.count
    end
  end

  def to_param
    incident_number
  end

  def to_label
    [incident_number, county.try(:name), date.to_s, incident_type, address].compact.join " "
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
    self.zip = geocode.zip
  end

  def close!
    response_date_cutoff = chapter.incidents_response_date_cutoff || 0

    self.status = 'closed'
    self.response_date = chapter.time_zone.today
    if chapter.time_zone.now.seconds_since_midnight < response_date_cutoff
      self.response_date = self.response_date.yesterday
    end
    dat_incident && dat_incident.valid? && save
  end

end
