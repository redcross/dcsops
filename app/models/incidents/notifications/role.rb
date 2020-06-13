module Incidents::Notifications
  class Role < ApplicationRecord
    belongs_to :region, class_name: 'Roster::Region'
    has_many :role_configurations

    has_many :positions, through: :role_configurations, class_name: 'Roster::Position'
    has_many :shift_territories, through: :role_configurations, class_name: 'Roster::ShiftTerritory'
    has_and_belongs_to_many :shifts, class_name: 'Scheduler::Shift'
    has_many :triggers, inverse_of: :role, dependent: :delete_all
    has_many :events, through: :triggers
    has_many :role_scopes, dependent: :delete_all

    validates :name, :region, presence: true

    accepts_nested_attributes_for :triggers, allow_destroy: true
    accepts_nested_attributes_for :role_scopes, allow_destroy: true
    accepts_nested_attributes_for :role_configurations, allow_destroy: true


    def self.for_region(region)
      where(region: region)
    end

    validate :validates_relations_in_same_region
    def validates_relations_in_same_region
    end

    def members
      (shift_members + position_territory_members).uniq
    end

    def shift_members
      shift_member_assignments.map(&:person)
    end

    def shift_member_assignments
      Scheduler::SchedulerService.new(region).scheduled_responders(shifts: shifts)
    end

    def position_territory_members
      Roster::Person.with_position(position_ids).in_shift_territory(shift_territory_ids)
    end

  end
end
