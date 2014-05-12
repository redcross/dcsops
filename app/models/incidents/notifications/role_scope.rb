module Incidents::Notifications
  class RoleScope < ActiveRecord::Base
    belongs_to :role

    assignable_values_for :level do
      %w(region county)
    end
  end
end
