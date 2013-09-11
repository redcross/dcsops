class Scheduler::Shift < ActiveRecord::Base
  belongs_to :shift_group
  belongs_to :county, class_name: 'Roster::County'


  has_and_belongs_to_many :positions, class_name: 'Roster::Position'
  has_many :shift_assignments

  validates :max_signups, numericality: true, presence: true
  validates :min_desired_signups, numericality: true, presence: true
  validates_presence_of :name, :abbrev

  def normalize_date date
    case shift_group.period
    when 'daily' then date
    when 'weekly' then date.at_beginning_of_week
    when 'monthly' then date.at_beginning_of_month
    end
  end

  def can_sign_up_on_day(date, num_assignments_on_day=nil)
    today = shift_group.chapter.time_zone.today

    return false if date < today and !allow_signup_in_past?(date)
    return false unless active_on_day? date
    return false if signups_frozen_before and date < signups_frozen_before
    return false if signups_available_before and date > signups_available_before
    num_days = (date - today).to_i
    return false if max_advance_signup and num_days > max_advance_signup
    return true if max_signups == 0

    if num_assignments_on_day
      assignments = num_assignments_on_day
    else
      assignments = shift_assignments.where(date: date).count
    end
    return assignments < max_signups
  end

  def allow_signup_in_past?(date)
    shift_assignments.build(date: date).local_end_time >= shift_group.chapter.time_zone.now
  end

  def can_remove_on_day(date)
    today = normalize_date shift_group.chapter.time_zone.today
    (date >= today) and (signups_frozen_before.nil? || (date >= signups_frozen_before))
  end

  def active_on_day?(date)
    return (shift_begins.nil? || shift_begins <= date) && (shift_ends.nil? || shift_ends > date)
  end

  scope :active_on_day, -> date {
    where{((shift_begins == nil) | (shift_begins <= date) & ((shift_ends == nil) | (shift_ends > date)))}
  }
  scope :for_county, -> county {
    where{county_id == county}
  }

  def can_be_taken_by?(person)
    if ignore_county or person.counties.to_a.include?(county)
      pos = positions & person.positions
      !pos.blank?
    else
      false
    end
  end

  def self.shifts_taken_by_day(shifts, month)
    days = (month..(month.end_of_month)).inject({}){|hash, date| hash[date]=0; hash}
    weeks = (month..(month.end_of_month)).select{|d| d.at_beginning_of_week == d }.inject({}){|hash, date| hash[date]=0; hash}
    months = {month => 0}

    empties = {'daily' => days, 'weekly' => weeks, 'monthly' => months}

    # This gets us the count signed up on each day
    shifts_by_id = shifts.reduce({}) do |hash, shift|
      hash[shift.id] = shift
      hash
    end

    groups_by_id = Scheduler::ShiftGroup.where{id.in(shifts_by_id.values.map(&:shift_group_id))}.reduce({}){|hash, group| hash[group.id] = group; hash }
    groups_by_shift_id = shifts_by_id.values.reduce({}) {|hash, shift| hash[shift.id] = groups_by_id[shift.shift_group_id]; hash}

    starter_hash = shifts_by_id.values.reduce({}) do |hash, shift|
      hash[shift] = empties[groups_by_shift_id[shift.id].period].dup
      hash
    end

    arr = Scheduler::ShiftAssignment.where{shift_id.in(shifts.to_a) & date.in(month..(month.at_end_of_month))}
                              .select{[count(id).as(:count), shift_id, date]}.group{shift_id}.group{date}.reduce(starter_hash) do |hash, ass|
      shift = shifts_by_id[ass.shift_id]
      if shift.nil?
        raise "Got unknown shift back from query #{ass.shift_id} #{shifts_by_id.inspect}"
      end

      if hash[shift][ass.date].nil?
        raise "Got unknown date back from query #{ass.date} #{shift.shift_group.period} #{hash.inspect}"
      end

      hash[shift][ass.date] += 1
      hash
    end

    # make sure we put in shifts that don't show up at all
    shifts.each do |shift|
      arr[shift] ||= days.dup
    end

    arr
  end

  def self.shifts_available_by_day(shifts, month, include_partial: true)
    ret = {}
    shifts_taken_by_day(shifts, month).each do |shift, dates|
      ret[shift] = dates.merge!(dates) do |date, count|
        shift.active_on_day?(date) && 
          (count == 0 || (include_partial and count < shift.max_signups))
      end
    end
    ret
  end

  def self.count_shifts_available_for_month(shifts, month, include_partial: true, only_future: true)
    shifts_available_by_day(shifts, month).map do |shift, dates|
      dates.map{|date, avail| (!only_future or date >= Date.current) && avail ? 1 : 0}.sum
    end.sum
  end

  #def shifts_taken_by_day(month, include_zeroes: true)
  #  days = include_zeroes ? (month..(month.end_of_month)).inject({}){|hash, date| hash[date]=0; hash} : {}
  #  shift_assignments.where("date >= ? and date <= ?", month, month.end_of_month).group(:date).select('count(id) as count, date').order(:date).inject(days){|hash, el| hash[el.date] = el.count; hash}
  #end
#
  #def shift_available_by_day(month, include_partial: true)
  #  shifts_taken_by_day(month).tap{|h|
  #    h.merge!(h){|k, v| v == 0 || (include_partial and v < max_signups)}
  #  }
  #end
#
  #def count_shifts_available_for_month(month, include_partial: true, only_future: true)
  #  shift_available_by_day(month).map{|date, avail| (!only_future or date >= Date.today) && avail ? 1 : 0}.sum
  #end

  def total_shifts_for_month(month)
    ((month.end_of_month)-month).to_i
  end
end
