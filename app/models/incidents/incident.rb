class Incidents::Incident < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'

  belongs_to :county, class_name: 'Roster::County'

  validates :chapter, :county, :incident_type, :date, presence: true
  validates :num_adults, :num_children, :num_families, :num_cases, :units_affected, presence: true, numericality: true
  validates :address, :cross_street, :city, :state, :zip, presence: true

  validates :incident_number, presence: true, format: /\A201[3-9]-\d+\z/, uniqueness: true

  def to_param
    incident_number
  end
end
