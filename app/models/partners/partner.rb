class Partners::Partner < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  include AutoGeocode

  validate :name, :chapter, presence: true
end
