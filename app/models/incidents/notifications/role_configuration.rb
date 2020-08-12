module Incidents::Notifications
  class RoleConfiguration < ActiveRecord::Base
    belongs_to :shift_territory, class_name: 'Roster::ShiftTerritory'
    belongs_to :position, class_name: 'Roster::Position'
    belongs_to :role
  end
end
