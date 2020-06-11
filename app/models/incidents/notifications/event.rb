module Incidents::Notifications
  class Event < ApplicationRecord
    belongs_to :region, class_name: 'Roster::Region'
    has_many :triggers
    has_many :roles, through: :triggers

    validates :region, :name, presence: true

    assignable_values_for :event_type do
      %w(event escalation)
    end

    def self.for_region region
      where{region_id == region}
    end

    def self.for_type type
      where{event_type == type}
    end

    def self.for_event_name name
      where{event == name}
    end
  end
end
