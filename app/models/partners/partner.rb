class Partners::Partner < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'
  include AutoGeocode

  validates :name, :region, presence: true
end
