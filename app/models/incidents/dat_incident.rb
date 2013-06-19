class Incidents::DatIncident < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  
  accepts_nested_attributes_for :incident#, reject_if: :cant_update_incident
  validates :address, :cross_street, :city, :state, :zip, presence: true

  validates :units_affected, :units_minor, :units_major, :units_destroyed, presence: true, numericality: true
  validates :num_people_injured, :num_people_hospitalized, :num_people_deceased, presence: true, numericality: true

  validates :incident_call_type, presence: true, inclusion: {in: %w(hot cold)}
  validates :incident_type, presence: true, inclusion: {in: %w(fire flood police)}

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

  def cant_update_incident
    !(incident.nil? || incident.new_record?)
  end

end
