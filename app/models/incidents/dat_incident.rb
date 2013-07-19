class Incidents::DatIncident < ActiveRecord::Base

  class TimesInCorrectOrder < ActiveModel::Validator
    MESSAGE = "%s must come before %s"
    def validate(record)
      return false unless record.responder_notified and record.responder_arrived and record.responder_departed
      [[:responder_notified, :responder_arrived], [:responder_arrived, :responder_departed]].each do |first_evt, second_evt|
        if record.send( first_evt ) > record.send(second_evt)
          record.errors[second_evt] = MESSAGE % [first_evt.to_s.titleize, second_evt.to_s.titleize]
        end
      end
    end
  end

  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :completed_by, class_name: 'Roster::Person'
  has_many :vehicle_uses, class_name: 'Incidents::VehicleUse', foreign_key: 'incident_id'
  has_many :vehicles, through: :vehicle_uses, class_name: 'Logistics::Vehicle'

  CALL_TYPES = %w(hot cold)
  INCIDENT_TYPES = %w(fire flood police)
  STRUCTURE_TYPES = %w(single_family_home apartment sro mobile_home commercial none)
  
  accepts_nested_attributes_for :incident, update_only: true#, reject_if: :cant_update_incident
  validates :address, :city, :state, :zip, presence: true # :cross_street

  validates :units_affected, :units_minor, :units_major, :units_destroyed, presence: true, numericality: true
  validates :num_adults, :num_children, :num_families, presence: true, numericality: true
  validates :num_people_injured, :num_people_hospitalized, :num_people_deceased, presence: true, numericality: true
  validates :comfort_kits_used, :blankets_used, presence: true, numericality: true

  validates :incident_call_type, presence: true, inclusion: {in: CALL_TYPES}
  validates :incident_type, presence: true, inclusion: {in: INCIDENT_TYPES}
  validates :structure_type, presence: true, inclusion: {in: STRUCTURE_TYPES}

  validates :responder_notified, :responder_arrived, :responder_departed, presence: true
  validates_with TimesInCorrectOrder

  validates :completed_by, presence: true

  serialize :services
  serialize :languages

  after_save :update_incident

  attr_accessor :search_for_address

  [:responder_notified=, :responder_arrived=, :responder_departed=].each do |sym|
    define_method sym do |val|
      if val.is_a? String
        super Chronic.parse(val)
      else
        super(val)
      end
    end
  end

  def update_incident
    if incident(true)
      incident.update_from_dat_incident
      update_timeline
    end
  end

  [:responder_notified, :responder_arrived, :responder_departed].each do |field|
    define_method :"#{field}=" do |val|
      if val.is_a? String
        super(Time.zone.parse(val))
      else
        super(val)
      end
    end
  end

  def update_timeline
    {'dat_received' => :responder_notified, 'dat_on_scene' => :responder_arrived, 'dat_departed_scene' => :responder_departed}.each do |event, attr|
      val = self.send(attr)
      if val
        incident.event_logs.where(event: event).first_or_initialize.update_attributes event_time: val
      end
    end
  end

  def units_total
    [units_affected, units_minor, units_major, units_destroyed].compact.sum
  end

  def cant_update_incident
    !(incident.nil? || incident.new_record?)
  end

end
