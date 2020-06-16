class Roster::Position < ApplicationRecord
  belongs_to :region
  has_many :position_memberships
  has_many :people, through: :position_memberships, class_name: 'Roster::Person'

  has_many :capability_memberships, class_name: 'Roster::CapabilityMembership'

  has_many :vc_position_configurations
  has_many :vc_positions, through: :vc_position_configurations, class_name: 'Roster::VcPosition'

  validates_presence_of :region, :name
  scope :visible, ->{where.not(hidden: true)}

  accepts_nested_attributes_for :capability_memberships, allow_destroy: true

  def display_name
    "#{region.short_name} - #{name}"
  end
end
