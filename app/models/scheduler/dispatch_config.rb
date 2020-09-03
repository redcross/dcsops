class Scheduler::DispatchConfig < ApplicationRecord
  self.table_name = :scheduler_dispatch_configs

  belongs_to :region, class_name: 'Roster::Region'
  belongs_to :shift_territory, class_name: 'Roster::ShiftTerritory'

  belongs_to :shift_first, class_name: 'Scheduler::Shift'
  belongs_to :shift_second, class_name: 'Scheduler::Shift'
  belongs_to :shift_third, class_name: 'Scheduler::Shift'
  belongs_to :shift_fourth, class_name: 'Scheduler::Shift'

  belongs_to :backup_first, class_name: 'Roster::Person'
  belongs_to :backup_second, class_name: 'Roster::Person'
  belongs_to :backup_third, class_name: 'Roster::Person'
  belongs_to :backup_fourth, class_name: 'Roster::Person'

  validates_presence_of :name, :region

  scope :active, ->{ where(is_active: true) }

  def self.for_shift_territory(shift_territory)
    self.where(shift_territory_id: shift_territory).first_or_create
  end

  def self.for_region region
    where(region: region)
  end

  def self.includes_everything
    includes(backup_first: :region).
    includes(backup_second: :region).
    includes(backup_third: :region).
    includes(backup_fourth: :region).
    includes(shift_first: [ :shift_territory, :shift_times ]).
    includes(shift_second: [ :shift_territory, :shift_times ]).
    includes(shift_third: [ :shift_territory, :shift_times ]).
    includes(shift_fourth: [ :shift_territory, :shift_times ]).
    includes(:region)
  end

  def self.with_shift shift
    where(shift_first: shift).
      or(Scheduler::DispatchConfig.where(shift_second: shift)).
      or(Scheduler::DispatchConfig.where(shift_third: shift)).
      or(Scheduler::DispatchConfig.where(shift_fourth: shift))
  end

  def shift_list
    [shift_first, shift_second, shift_third, shift_fourth].compact
  end

  def backup_list
    [backup_first, backup_second, backup_third, backup_fourth].compact
  end

  def display_name
    "#{region_id} - #{name}"
  end
end
