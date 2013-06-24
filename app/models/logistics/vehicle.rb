class Logistics::Vehicle < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'

  CATEGORIES = %w(erv suv shelter_trailer misc)

  validates :category, presence: true, inclusion: {in: CATEGORIES}
end
