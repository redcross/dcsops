class Partners::Partner < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  include AutoGeocode

  validates :name, :chapter, presence: true
end
