class Scheduler::ShiftCategory < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'
  has_many :shifts, class_name: 'Scheduler::Shift'

  def self.for_region region
    where(region: region)
  end

  def self.enabled
    where(enabled: true)
  end

  def display_name
    "#{region.name} - #{name}"
  end

  default_scope { order(:region_id).order(:ordinal) }
end
