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
  STRUCTURE_TYPES = %w(single_family_home apartment sro mobile_home)
  
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

  # Temp fields for form work
  attr_accessor :canteened_responders, :canteened_clients, :meal_provided, :meal_meals, :meal_vendor#:breakfast_provided, :breakfast_meals, :breakfast_vendor, :lunch_provided, :lunch_meals, :lunch_vendor, :dinner_provided, :dinner_meals, :dinner_vendor
  attr_accessor :evac_facility_name, :shelter_facility_name, :hotel_name, :hotel_rate
  attr_accessor :languages

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
    if responder_notified
      incident.event_logs.where(event: 'dat_received').first_or_initialize.update_attributes event_time: responder_notified
    end
    if responder_arrived
      incident.event_logs.where(event: 'dat_on_scene').first_or_initialize.update_attributes event_time: responder_arrived
    end
    if responder_departed
      incident.event_logs.where(event: 'dat_departed_scene').first_or_initialize.update_attributes event_time: responder_departed
    end
  end

  def units_total
    [units_affected, units_minor, units_major, units_destroyed].compact.sum
  end

  def cant_update_incident
    !(incident.nil? || incident.new_record?)
  end

end
