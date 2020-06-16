class Roster::CapabilityMembership < ActiveRecord::Base
  belongs_to :position
  belongs_to :capability
  has_many :capability_scopes

  accepts_nested_attributes_for :capability_scopes, allow_destroy: true
  validates :position, :capability, presence: true

  def display_name
    "#{capability.try :name} - (#{capability_scopes.map(&:scope).join ','})"
  end
end
