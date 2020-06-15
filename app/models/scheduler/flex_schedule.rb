class Scheduler::FlexSchedule < ApplicationRecord
  belongs_to :person, foreign_key: 'id', class_name: 'Roster::Person'

  scope :for_shift_territory, lambda {|shift_territory_ids| 
    joins(person: :shift_territory_memberships).where{person.shift_territory_memberships.county_id.in my{shift_territory_ids}}
  }

  scope :with_availability, lambda {
    where{
      Scheduler::FlexSchedule.available_columns.map{|c|__send__(c) == true}.reduce(&:|)
    }
  }

  scope :available_at, lambda { |day, shift|
    where("available_#{day}_#{shift}" => true)
  }

  def self.by_distance_from inc
    joins(:person).order{_(person.lat.op(:-, inc.lat)).op('^', 2).op(:+, _(person.lng.op(:-, inc.lng)).op('^', 2))}
  end

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
