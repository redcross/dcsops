class Incidents::Deployment < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person'

  validates_presence_of :person
end
