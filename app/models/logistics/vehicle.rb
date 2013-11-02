class Logistics::Vehicle < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'

  assignable_values_for :category do
    %w(erv suv shelter_trailer misc pov)
  end

  scope :for_chapter, ->(chapter){where{chapter_id == chapter}}
end
