class Partners::Partner < ActiveRecord::Base
  include AutoGeocode

  validate :name, presence: true
end
