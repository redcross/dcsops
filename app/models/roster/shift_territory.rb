class Roster::ShiftTerritory < ActiveRecord::Base
  belongs_to :region
  has_many :shift_territory_memberships
  has_many :people, through: :shift_territory_memberships, class_name: 'Roster::Person'

  has_many :vc_position_configurations
  has_many :vc_positions, through: :vc_position_configurations, class_name: 'Roster::VcPosition'

  validates_presence_of :region

  default_scope {order(:name)}

  def self.enabled
    where(enabled: true)
  end

  def display_name
    "#{region.short_name} - #{name}"
  end
end
