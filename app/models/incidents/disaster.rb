class Incidents::Disaster < ActiveRecord::Base
  has_many :deployments, class_name: 'Incidents::Deployment'
end
