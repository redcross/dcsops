class Scheduler::FlexSchedule < ActiveRecord::Base
  belongs_to :person, foreign_key: 'id', class_name: 'Roster::Person'

  scope :for_county, lambda {|county_ids| 
    joins{person.county_memberships}.where{person.county_memberships.county_id.in my{county_ids}}
  }

  scope :with_availability, lambda {
    where(
      Scheduler::FlexSchedule.available_columns.map{|c| "#{c} = 't'"}.join " OR "
    )
  }

  scope :available_at, lambda { |day, shift|
    where("available_#{day}_#{shift}".to_sym => true)
  }

  scope :with_position, lambda {|county| joins{person.positions}.where{person.positions.id.in(county)}}

  def available(day, shift)
    self.send "available_#{day}_#{shift}".to_sym
  end

  def num_shifts
    shifts = 0
    self.class.days.each do |day|
      self.class.shifts.each do |shift|
        shifts = shifts+1 if available(day, shift)
      end
    end
    shifts
  end

  def self.days; %w(sunday monday tuesday wednesday thursday friday saturday); end
  def self.shifts; %w(day night); end
  def self.available_columns
    self.days.map do |day|
      self.shifts.map do |shift|
        "available_#{day}_#{shift}"
      end
    end.flatten
  end
end
