class Roster::Chapter < ActiveRecord::Base
  has_many :counties
  has_many :positions
  has_many :people
end
