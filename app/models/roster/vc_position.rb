class Roster::VcPosition < ActiveRecord::Base
  belongs_to :region, class_name: 'Roster::Region'
  has_many :vc_position_configurations

  has_many :positions, through: :vc_position_configurations
  has_many :shift_territories, through: :vc_position_configurations

  accepts_nested_attributes_for :vc_position_configurations, allow_destroy: true
end
