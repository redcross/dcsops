class Scheduler::DispatchConfig < ActiveRecord::Base
  self.table_name = :scheduler_dispatch_configs

  belongs_to :county, class_name: 'Roster::County'
  belongs_to :backup_first, class_name: 'Roster::Person'
  belongs_to :backup_second, class_name: 'Roster::Person'
  belongs_to :backup_third, class_name: 'Roster::Person'
  belongs_to :backup_fourth, class_name: 'Roster::Person'

  validates_presence_of :name, :county

  scope :active, ->{ where{is_active == true} }

  def self.for_county(county)
    self.where(county_id: county).first_or_create
  end

  def backup_list
    [backup_first, backup_second, backup_third, backup_fourth].compact
  end

  def self.for_chapter chapter
    joins{county}.where{county.chapter_id == chapter}
  end
end
