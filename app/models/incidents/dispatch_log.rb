class Incidents::DispatchLog < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :chapter, class_name: 'Roster::Chapter'

  has_many :log_items, class_name: 'Incidents::DispatchLogItem'
end
