module Incidents::Notifications
  class RoleScope < ApplicationRecord
    belongs_to :role
    belongs_to :response_territory, class_name: 'Incidents::ResponseTerritory'

    validates_presence_of :response_territory, if: ->(obj){obj.level == 'response_territory'}

    assignable_values_for :level do
      %w(region response_territory shift_territory)
    end

    before_validation :clean_values
    def clean_values
      if level == 'response_territory'
        value = nil
      else
        response_territory_id = nil
      end
    end
  end
end
