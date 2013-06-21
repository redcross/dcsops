class Incidents::DatIncident < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'

  CALL_TYPES = %w(hot cold)
  INCIDENT_TYPES = %w(fire flood police)
  STRUCTURE_TYPES = %w(single_family_home apartment sro mobile_home)
  
  accepts_nested_attributes_for :incident, update_only: true#, reject_if: :cant_update_incident
  validates :address, :city, :state, :zip, presence: true # :cross_street

  validates :units_affected, :units_minor, :units_major, :units_destroyed, presence: true, numericality: true
  validates :num_adults, :num_children, :num_families, presence: true, numericality: true
  validates :num_people_injured, :num_people_hospitalized, :num_people_deceased, presence: true, numericality: true

  validates :incident_call_type, presence: true, inclusion: {in: CALL_TYPES}
  validates :incident_type, presence: true, inclusion: {in: INCIDENT_TYPES}
  validates :structure_type, presence: true, inclusion: {in: STRUCTURE_TYPES}

  validates :responder_notified, :responder_arrived, :responder_departed, presence: true

  serialize :services

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
    incident.update_from_dat_incident if incident
  end

  def units_total
    [units_affected, units_minor, units_major, units_destroyed].compact.sum
  end

  def cant_update_incident
    !(incident.nil? || incident.new_record?)
  end

end
