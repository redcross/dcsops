module Incidents::Notifications
  class Event < ActiveRecord::Base
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
  end
end
