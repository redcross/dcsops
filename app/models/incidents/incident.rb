class Incidents::Incident < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :county, class_name: 'Roster::County'

  has_many :responder_assignments, class_name: 'Incidents::ResponderAssignment'
  has_one :team_lead, {class_name: 'Incidents::ResponderAssignment'}, lambda{ where(role: 'team_lead') }

  has_one :cas_incident, class_name: 'Incidents::CasIncident'

  validates :chapter, :county, :date, presence: true
  validates :num_adults, :num_children, :num_families, :num_cases, :units_affected, presence: true, numericality: true
  validates :address, :cross_street, :city, :state, :zip, presence: true

  validates :incident_call_type, presence: true, inclusion: {in: %w(hot cold)}
  validates :incident_type, presence: true, inclusion: {in: %w(fire flood police)}
  validates :incident_number, presence: true, format: /\A1[3-9]-\d+\z/, uniqueness: true

  validates :team_lead_id, presence: true, on: :create
  validate :team_lead_is_person, on: :create

  after_create :create_team_lead

  attr_accessor :team_lead_id

  def team_lead_is_person
    unless Roster::Person.where(id: team_lead_id).count == 1
      errors[:team_lead_id] << "is not a person"
      false
    end
  end

  def create_team_lead
    person = Roster::Person.where(id: team_lead_id).first
    responder_assignments.create! role: 'team_lead', person: person
  end

  def to_param
    incident_number
  end

  scope :incident_stats, lambda {
    order(nil).select{[count(id).as(:incident_count), sum(num_cases).as(:case_count), sum(num_adults + num_children).as(:client_count)]}.first
  }
end
