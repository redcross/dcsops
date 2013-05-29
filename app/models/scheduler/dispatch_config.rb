class Scheduler::DispatchConfig < ActiveRecord::Base
  self.table_name = :scheduler_dispatch_configs

  belongs_to :county, class_name: 'Roster::County', foreign_key: 'id'
  belongs_to :backup_first, class_name: 'Roster::Person'
  belongs_to :backup_second, class_name: 'Roster::Person'
  belongs_to :backup_third, class_name: 'Roster::Person'
  belongs_to :backup_fourth, class_name: 'Roster::Person'

  has_and_belongs_to_many :receives_admin_notifications, class_name: 'Roster::Person', join_table: :scheduler_dispatch_configs_admin_notifications

  validates_presence_of :county

  def self.for_county(county)
    self.where(id: county).first_or_create
  end

  def backup_list
    [backup_first, backup_second, backup_third, backup_fourth].compact
  end
end
