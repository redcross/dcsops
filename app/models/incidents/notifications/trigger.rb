module Incidents::Notifications
  class Trigger < ApplicationRecord
    belongs_to :role, inverse_of: :triggers
    belongs_to :event

    validates_uniqueness_of :event_id, scope: :role_id
    validates :role, :event, :template, presence: true

    TEMPLATES = %w(notification activation mobilization)

    assignable_values_for :template do
      TEMPLATES
    end
  end
end
