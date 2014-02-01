class Roster::PositionMembership < Roster::Membership
  belongs_to :position
  has_many :roles, through: :position
end