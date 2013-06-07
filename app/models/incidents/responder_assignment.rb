class Incidents::ResponderAssignment < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :incident, class_name: 'Incidents::Incident'
end
