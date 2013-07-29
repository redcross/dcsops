class Incidents::Incident < ActiveRecord::Base
  INVALID_INCIDENT_TYPES = %w(invalid duplicate not_eligible_for_services)

  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :county, class_name: 'Roster::County'

  has_one :cas_incident, class_name: 'Incidents::CasIncident'
  has_one :dat_incident, class_name: 'Incidents::DatIncident'
  has_one :dispatch_log, class_name: 'Incidents::DispatchLog'
  
  has_many :event_logs, ->{ order{event_time} }, class_name: 'Incidents::EventLog'
  has_one :latest_event_log, ->{ order{event_time.desc}.where{event != 'note'} }, class_name: 'Incidents::EventLog'

  has_many :responder_assignments, lambda { where{role != 'team_lead'}}, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_many :all_responder_assignments, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_many :on_scene_responder_assignments, lambda { on_scene }, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_one :team_lead, lambda{ where(role: 'team_lead')}, class_name: 'Incidents::ResponderAssignment', foreign_key: 'incident_id'

  {evac_partner: 'evac_center', hotel_partner: 'hotel', shelter_partner: 'shelter', feeding_partner: 'feeding'}.each do |attr, role|
    has_one :"#{attr}_use", -> { where(role: role) }, class_name: 'Incidents::PartnerUse'

    accepts_nested_attributes_for :"#{attr}_use", update_only: true, reject_if: -> attrs { attrs[:partner_id].blank? && attrs[:partner_name].blank? }
    validates_presence_of :"#{attr}_use", if: :"#{attr}_used"
    validates_associated :"#{attr}_use", if: :"#{attr}_used"
    #attr_accessor :"#{attr}_used"
    #define_method :"#{attr}_used=" do |val|
    #  coerced = case val
    #  when TrueClass, FalseClass then val
    #  when String then val=='1'
    #  else false
    #  end
    #  write_attribute("@#{attr}_used", coerced)
    #end

    before_validation :"clean_#{attr}_use"
    define_method :"clean_#{attr}_use" do
      use = self.send :"#{attr}_use"
      used = self.send :"#{attr}_used"
      if !used and use
        use.destroy
        self.send(:"#{attr}_use=", nil)
      end
    end
  end

  accepts_nested_attributes_for :team_lead, update_only: true
  accepts_nested_attributes_for :responder_assignments, reject_if: -> hash {(hash[:person_id].blank?)}, allow_destroy: true


  validates :chapter, :county, :date, presence: true
  validates :incident_number, presence: true, format: /\A1[3-9]-\d+\z/, uniqueness: true
  validates_associated :team_lead, if: ->(inc) {inc.dat_incident}, allow_nil: false

  #delegate :address,  :city, :state, :zip, :lat, :lng, :num_adults, :num_children, to: :dat_incident
  #delegate :units_affected, to: :dat_incident

  scope :in_county, -> county {where{county_id == county}}
  scope :incident_stats, lambda {
    valid.order(nil).select{[count(id).as(:incident_count), sum(num_cases).as(:case_count), sum(num_families).as(:family_count), sum(num_adults + num_children).as(:client_count)]}.first
  }
  scope :valid, lambda {
    where{incident_type.not_in(INVALID_INCIDENT_TYPES) | (incident_type == nil)}
  }
  scope :needs_incident_report, lambda {
    valid.joins{dat_incident.outer}.where{(dat_incident.id == nil) & ((ignore_incident_report != true) | (ignore_incident_report == nil))}
  }
  scope :open_cases, lambda {
    valid.joins{cas_incident.cases.outer}.where{((cas_incident.cases_open > 0) | (cas_incident.last_date_with_open_cases >= 7.days.ago)) & (cas_incident.cases.case_last_updated > 2.months.ago)}
  }

  def update_from_dat_incident
    address_fields = [:address,  :city, :state, :zip, :lat, :lng, :num_adults, :num_children, :num_families, :incident_type]
    if dat_incident
      address_fields.each do |f|
        self.send "#{f}=", dat_incident.send(f)
      end
    end
    save
  end

  def update_from_cas
    if cas_incident
      self.num_cases = cas_incident.cases.count
    end
    save
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

  def county_name
    county.try :name
  end

  def services_description
    dat = dat_incident
    dat.services && dat.services.map(&:titleize).to_sentence
  end

  def to_label
    [incident_number, county.try(:name), date.to_s, dat_incident.try(:incident_type)].compact.join " "
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
end
