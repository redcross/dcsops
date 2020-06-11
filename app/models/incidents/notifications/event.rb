module Incidents::Notifications
  class Event < ApplicationRecord
    belongs_to :chapter, class_name: 'Roster::Chapter'
    has_many :triggers
    has_many :roles, through: :triggers

    validates :chapter, :name, presence: true

    assignable_values_for :event_type do
      %w(event escalation)
    end

    def self.for_chapter chapter
      where{chapter_id == chapter}
    end

    def self.for_type type
      where{event_type == type}
    end

    def self.for_event_name name
      where{event == name}
    end
  end
end
