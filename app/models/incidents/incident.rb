class Incidents::Incident < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :county, class_name: 'Roster::County'

  has_one :cas_incident, class_name: 'Incidents::CasIncident'
  has_one :dat_incident, class_name: 'Incidents::DatIncident'
  has_many :event_logs, ->{ order{event_time} }, class_name: 'Incidents::EventLog'
  has_one :latest_event_log, ->{ order{event_time.desc}.where{event != 'note'} }, class_name: 'Incidents::EventLog'

  validates :chapter, :county, :date, presence: true
  validates :incident_number, presence: true, format: /\A1[3-9]-\d+\z/, uniqueness: true

  #delegate :address,  :city, :state, :zip, :lat, :lng, :num_adults, :num_children, to: :dat_incident
  #delegate :units_affected, to: :dat_incident

  scope :in_county, -> county {where{county_id == county}}

  def update_from_dat_incident
    address_fields = [:address,  :city, :state, :zip, :lat, :lng, :num_adults, :num_children, :num_families]
    if dat_incident
      address_fields.each do |f|
        self.send "#{f}=", dat_incident.send(f)
      end
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

  scope :incident_stats, lambda {
    order(nil).select{[count(id).as(:incident_count), sum(num_cases).as(:case_count), sum(num_adults + num_children).as(:client_count)]}.first
  }
end
