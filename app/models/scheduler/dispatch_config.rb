class Scheduler::DispatchConfig < ApplicationRecord
  self.table_name = :scheduler_dispatch_configs

  belongs_to :chapter, class_name: 'Roster::Chapter'
  belongs_to :county, class_name: 'Roster::County'

  belongs_to :shift_first, class_name: 'Scheduler::Shift'
  belongs_to :shift_second, class_name: 'Scheduler::Shift'
  belongs_to :shift_third, class_name: 'Scheduler::Shift'
  belongs_to :shift_fourth, class_name: 'Scheduler::Shift'

  belongs_to :backup_first, class_name: 'Roster::Person'
  belongs_to :backup_second, class_name: 'Roster::Person'
  belongs_to :backup_third, class_name: 'Roster::Person'
  belongs_to :backup_fourth, class_name: 'Roster::Person'

  validates_presence_of :name, :chapter

  scope :active, ->{ where{is_active == true} }

  def self.for_county(county)
    self.where(county_id: county).first_or_create
  end

  def self.for_chapter chapter
    where(chapter: chapter)
  end

  def self.includes_everything
    shifts = :shift_first, :shift_second, :shift_third, :shift_fourth
    backups = :backup_first, :backup_second, :backup_third, :backup_fourth
    includes do
      backups.map{|b| __send__(b).chapter }
    end.includes do
      shifts.flat_map{|sh| [__send__(sh).county,__send__(sh).shift_groups] }
    end.includes(:chapter)
  end

  def self.with_shift shift
    shifts = :shift_first_id, :shift_second_id, :shift_third_id, :shift_fourth_id
    where do
      shifts.map{|sh| __send__(sh) == shift }.reduce(&:|)
    end
  end

  def shift_list
    [shift_first, shift_second, shift_third, shift_fourth].compact
  end

  def backup_list
    [backup_first, backup_second, backup_third, backup_fourth].compact
  end

  def display_name
    "#{chapter_id} - #{name}"
  end
end
