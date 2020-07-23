class Roster::VcPositionConfiguration < ActiveRecord::Base
  belongs_to :shift_territory
  belongs_to :position
  belongs_to :vc_position

  scope :for_region, -> region {
    joins{vc_position}.where{vc_position.region_id == region}
  }
end

