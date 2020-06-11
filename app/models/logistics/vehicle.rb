class Logistics::Vehicle < ApplicationRecord
  belongs_to :chapter, class_name: 'Roster::Chapter'
  include AutoGeocode
  self.geocode_columns = %w(address city state zip)

  assignable_values_for :category do
    %w(erv suv shelter_trailer misc pov)
  end

  scope :for_chapter, ->(chapter){where{chapter_id == chapter}}
end
