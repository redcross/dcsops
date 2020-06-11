class Logistics::Vehicle < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'
  include AutoGeocode
  self.geocode_columns = %w(address city state zip)

  assignable_values_for :category do
    %w(erv suv shelter_trailer misc pov)
  end

  scope :for_region, ->(region){where{region_id == region}}
end
