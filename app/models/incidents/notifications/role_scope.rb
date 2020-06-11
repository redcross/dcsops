module Incidents::Notifications
  class RoleScope < ApplicationRecord
    belongs_to :role
    belongs_to :territory, class_name: 'Incidents::Territory'

    validates_presence_of :territory, if: ->(obj){obj.level == 'territory'}

    assignable_values_for :level do
      %w(region territory county)
    end

    before_validation :clean_values
    def clean_values
      if level == 'territory'
        value = nil
      else
        territory_id = nil
      end
    end
  end
end
