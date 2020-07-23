class Roster::VcPosition < ActiveRecord::Base
  belongs_to :region, class_name: 'Roster::Region'
  has_many :vc_position_configurations
end
