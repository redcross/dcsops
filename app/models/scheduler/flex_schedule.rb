class Scheduler::FlexSchedule < ApplicationRecord
  belongs_to :person, foreign_key: 'id', class_name: 'Roster::Person'

  scope :for_shift_territory, lambda {|shift_territory_ids| 
    joins(person: :shift_territory_memberships).where(person: { roster_shift_territory_memberships: { shift_territory_id: shift_territory_ids } })
  }

  scope :with_availability, lambda {
    # Squeel migration note:
    #
    # The original squeel was:
    #  where{
    #    Scheduler::FlexSchedule.available_columns.map{|c|__send__(c) == true}.reduce(&:|)
    #  }
    #
    # That's a pretty elegant way to do what is exploded manually below.  There may be a
    # better way to do it in native active record, but I don't know it.
    where(available_sunday_day: true).
      or(Scheduler::FlexSchedule.where(available_sunday_night: true)).
      or(Scheduler::FlexSchedule.where(available_monday_day: true)).
      or(Scheduler::FlexSchedule.where(available_monday_night: true)).
      or(Scheduler::FlexSchedule.where(available_tuesday_day: true)).
      or(Scheduler::FlexSchedule.where(available_tuesday_night: true)).
      or(Scheduler::FlexSchedule.where(available_wednesday_day: true)).
      or(Scheduler::FlexSchedule.where(available_wednesday_night: true)).
      or(Scheduler::FlexSchedule.where(available_thursday_day: true)).
      or(Scheduler::FlexSchedule.where(available_thursday_night: true)).
      or(Scheduler::FlexSchedule.where(available_friday_day: true)).
      or(Scheduler::FlexSchedule.where(available_friday_night: true)).
      or(Scheduler::FlexSchedule.where(available_saturday_day: true)).
      or(Scheduler::FlexSchedule.where(available_saturday_night: true))
  }

  scope :available_at, lambda { |day, shift|
    where("available_#{day}_#{shift}" => true)
  }

  def self.by_distance_from inc
    distance_select_clause = sanitize_sql_array(['(roster_people.lat - ?)^2 + (roster_people.lng - ?)^2 AS distance', inc.lat, inc.lng])
    joins(:person).select('*').select(distance_select_clause).order(:distance)
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
