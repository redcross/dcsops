class Incidents::Incident < ApplicationRecord
  include HasDelegatedValidators
  include Incidents::IncidentPartners
  include Mappable

  has_paper_trail class_name: 'Version', meta: {region_id: ->(inc){inc.region_id}}

  before_validation :set_incident_number, on: :create

  belongs_to :region, class_name: 'Roster::Region'
  belongs_to :shift_territory, class_name: 'Roster::ShiftTerritory'
  belongs_to :response_territory, class_name: 'Incidents::ResponseTerritory'

  belongs_to :cas_incident, class_name: 'Incidents::CasIncident', primary_key: 'cas_incident_number', foreign_key: 'cas_event_number'
  has_one :dat_incident, class_name: 'Incidents::DatIncident', inverse_of: :incident
  has_one :dispatch_log, class_name: 'Incidents::DispatchLog'
  has_many :responder_messages, class_name: 'Incidents::ResponderMessage'
  has_many :responder_recruitments, class_name: 'Incidents::ResponderRecruitment'
  
  has_many :event_logs, -> { order(event_time: :desc) }, class_name: 'Incidents::EventLog', inverse_of: :incident
  has_many :attachments, class_name: 'Incidents::Attachment', inverse_of: :incident
  has_many :cases, class_name: 'Incidents::Case', inverse_of: :incident
  has_one :initial_incident_report, class_name: 'Incidents::InitialIncidentReport', inverse_of: :incident

  has_many :responder_assignments, lambda { where.not(role: 'team_lead')}, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id, inverse_of: :incident
  has_many :all_responder_assignments, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_one :team_lead, lambda{ where(role: 'team_lead')}, class_name: 'Incidents::ResponderAssignment', foreign_key: 'incident_id'

  belongs_to :current_dispatch_contact, class_name: "Roster::Person"

  belongs_to :notification_level, class_name: 'Incidents::Notifications::Event'

  accepts_nested_attributes_for :team_lead, update_only: true
  accepts_nested_attributes_for :responder_assignments, reject_if: -> hash {(hash[:person_id].blank?)}, allow_destroy: true
  accepts_nested_attributes_for :event_logs

  # We always want these to be present
  validates :region, :date, :response_territory, presence: true
  validates :incident_number, presence: true, format: /\A\w*\d{2}-\d{3,}\z/, uniqueness: { scope: :region_id }

  scope :for_region, -> (region) { where(region: region) }
  scope :in_shift_territory, -> area {where(shift_territory_id: shift_territory)}
  scope :valid, -> { where.not(status: 'invalid') }
  scope :with_status, -> (filter_status) { where(status: filter_status) }
  scope :needs_incident_report, lambda {
    with_status 'open'
  }
  scope :without_cas, -> {
    left_outer_joins(:cas_incident).where(cas_incident: { id: nil })
  }
  scope :with_date_in, -> date_range {
    where(date: date_range)
  }
  scope :with_county, -> county_in {
    where(county: county_in)
  }

  def self.with_location
    where.not(lat: nil, lng: nil).where.not(lat: 0, lng: 0)
  end

  def self.incident_stats
    OpenStruct.new({
      incident_count: valid.count,
      case_count:     valid.sum(:num_cases),
      family_count:   valid.sum(:num_families),
      client_count:   valid.sum(:num_adults) + valid.sum(:num_children),
      num_adults:     valid.sum(:num_adults),
      num_children:   valid.sum(:num_children)
    })
  end

  def self.count_resources resources
    rec = joins(:dat_incident).unscope(:order).select do
      resources.map do |res|
        sum(coalesce(cast(dat_incident.resources.op('->>', res).as(integer)), 0)).as(res)
      end
    end.take
    rec && rec.attributes.slice(*resources) || {}
  end

  assignable_values_for :incident_type, allow_blank: true do
    valid_incident_types
  end

  assignable_values_for :reason_marked_invalid, allow_blank: true do
    self.class.invalid_incident_types
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

  def dispatched?
    event_logs.for_type("dispatch_relayed").exists?
  end

  def self.main_incident_types
    %w(fire flood police vacate tornado blizzard storm transportation hazmat explosion search_and_rescue earthquake building_collapse exercise hurricane public_health)
  end

  def self.extended_incident_types
    %w(outreach dhs drought epidemic food hpd hra mass_care nuclear other refugee volcano client_services_request power_outage)
  end

  def valid_incident_types
    types = self.class.main_incident_types
    types += self.class.extended_incident_types if region && region.incidents_report_advanced_details
    types
  end

  def humanized_valid_incident_types
    valid_incident_types.map{|t| AssignableValues::HumanizedValue.new(t, t.titleize)}
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
    persisted? && incident_number
  end

  def to_label
    [incident_number, county.try(:name), date.to_s, incident_type, address].compact.join " "
  end

  def county_state
    "#{county}, #{state}"
  end

  def link_to_cas_incident(cas)
    raise "Already have a CAS Incident" if cas_incident.present?
    raise "CAS Incident is already linked" if cas.incident.present?


    self.class.transaction do 
      self.cas_event_number = cas.cas_incident_number
      cas.incident = self
      self.save!
      cas.save!
    end
  end

  def timeline
    @timeline ||= Incidents::TimelineProxy.new(self)
  end

  def timeline_attributes=(attrs)
    timeline.attributes = attrs
  end

  def set_incident_number
    if region && (seq = region.incident_number_sequence)
      self.incident_number = seq.next_sequence!
    end
  end

  def take_location_from geocode
    return unless geocode.success?
    self.lat = geocode.lat
    self.lng = geocode.lng
    self.city = geocode.city
    self.county = geocode.district.try(:gsub, ' County', '')
    self.state = geocode.state
    self.zip = geocode.zip
  end

  def close!
    self.status = 'closed'
    self.response_date = region.time_zone.today
    dat_incident && dat_incident.valid? && save
  end

  def force_close!
    self.status = 'closed'
    self.response_date = region.time_zone.today
    save(:validate => false)
  end

end
