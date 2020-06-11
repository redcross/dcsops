class Partners::Partner < ApplicationRecord
  belongs_to :chapter, class_name: 'Roster::Chapter'
  include AutoGeocode

  validates :name, :chapter, presence: true
end
