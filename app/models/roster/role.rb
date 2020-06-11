class Roster::Role < ApplicationRecord
  has_many :role_memberships, class_name: 'Roster::RoleMembership'
  validates :name, :grant_name, presence: true

  def display_name
    "#{name} (#{grant_name})"
  end
end
