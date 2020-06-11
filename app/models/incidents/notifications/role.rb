module Incidents::Notifications
  class Role < ApplicationRecord
    belongs_to :chapter, class_name: 'Roster::Chapter'
    has_and_belongs_to_many :positions, class_name: 'Roster::Position'
    has_and_belongs_to_many :shifts, class_name: 'Scheduler::Shift'
    has_many :triggers, inverse_of: :role, dependent: :delete_all
    has_many :events, through: :triggers
    has_many :role_scopes, dependent: :delete_all

    validates :name, :chapter, presence: true

    accepts_nested_attributes_for :triggers, allow_destroy: true
    accepts_nested_attributes_for :role_scopes, allow_destroy: true

    def self.for_chapter(chapter)
      where{chapter_id == chapter}
    end

    validate :validates_relations_in_same_chapter
    def validates_relations_in_same_chapter
    end

    def members
      (shift_members + position_members).uniq
    end

    def shift_members
      shift_member_assignments.map(&:person)
    end

    def shift_member_assignments
      Scheduler::SchedulerService.new(chapter).scheduled_responders(shifts: shifts)
    end

    def position_members
      Roster::Person.with_position(position_ids)
    end

  end
end
