class Incidents::DatIncident < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  has_many :responder_assignments, lambda { where{role != 'team_lead'}}, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id 
  has_many :all_responder_assignments, class_name: 'Incidents::ResponderAssignment', foreign_key: :incident_id
  has_one :team_lead, lambda{ where(role: 'team_lead')}, class_name: 'Incidents::ResponderAssignment', foreign_key: 'incident_id'

  accepts_nested_attributes_for :incident, reject_if: :cant_update_incident
  accepts_nested_attributes_for :team_lead
  accepts_nested_attributes_for :responder_assignments, reject_if: -> hash {(hash[:person_id].blank? || hash[:role].blank?)}, allow_destroy: true

  validates :num_adults, :num_children, :num_families, :units_total, presence: true, numericality: true
  validates :address, :cross_street, :city, :state, :zip, presence: true

  validates :incident_call_type, presence: true, inclusion: {in: %w(hot cold)}
  validates :incident_type, presence: true, inclusion: {in: %w(fire flood police)}

  validates_associated :team_lead

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
