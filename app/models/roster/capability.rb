class Roster::Capability < ActiveRecord::Base
  has_many :capability_memberships, class_name: 'Roster::CapabilityMembership'
  validates :name, :grant_name, presence: true

  def display_name
    "#{name} (#{grant_name})"
  end
end
