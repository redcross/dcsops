class Roster::RoleMembership < ApplicationRecord
  belongs_to :position
  belongs_to :role
  has_many :role_scopes

  accepts_nested_attributes_for :role_scopes, allow_destroy: true
  validates :position, :role, presence: true

  def display_name
    "#{role.try :name} - (#{role_scopes.map(&:scope).join ','})"
  end
end
