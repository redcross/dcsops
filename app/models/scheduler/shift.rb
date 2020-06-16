class Scheduler::Shift < ApplicationRecord
  belongs_to :shift_territory, class_name: 'Roster::ShiftTerritory'
  has_one :region, class_name: 'Roster::Region', through: :shift_territory
  belongs_to :shift_category, class_name: 'Scheduler::ShiftCategory'

  has_and_belongs_to_many :positions, class_name: 'Roster::Position'
  has_and_belongs_to_many :shift_times, class_name: 'Scheduler::ShiftTime'
  has_many :shift_assignments

  validates :shift_territory, :shift_category, presence: true
  validates :max_signups, numericality: true, presence: true
  validates :min_desired_signups, numericality: true, presence: true
  validates_presence_of :name, :abbrev, :ordinal

  assignable_values_for :vc_hours_type, allow_blank: true do
    %w(oncall worked)
  end

  def check_shift_time group
    #unless shift_time_ids.include? group.id
    #  raise "That shift time does not belong to this shift"
    #end
  end

  def normalize_date date, shift_time
    shift_time.normalize_date date
  end

  def unfrozen_on(date)
    (signups_frozen_before.nil? || (date >= signups_frozen_before)) and
      (signups_available_before.nil? || (date <= signups_available_before))
  end

  def can_sign_up_on_day(date, shift_time, num_assignments_on_day=nil, today=nil)
    check_shift_time shift_time
    today ||= shift_time.region.time_zone.today

    return false if date < today and !allow_signup_in_past?(date, shift_time)
    return false unless active_on_day? date, shift_time
    return false unless unfrozen_on(date)
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

  def allow_signup_in_past?(date, shift_time)
    check_shift_time shift_time
    tz = shift_time.region.time_zone
    key = (shift_time.period == 'monthly' ? :days : :seconds)
    Scheduler::ShiftTimeCalculator.new(tz).local_offset(date, key => shift_time.end_offset) >= tz.now
    #pp(Scheduler::ShiftAssignment.new(date: date, shift: self, shift_time: shift_time).local_end_time) >= tz.now
  end

  def can_remove_on_day(date, shift_time, today=nil)
    check_shift_time shift_time
    today ||= shift_time.region.time_zone.today
    today = normalize_date today, shift_time
    advance = date - today
    (date >= today) and unfrozen_on(date) and (advance >= min_advance_signup)
  end

  def active_on_day?(date, shift_time)
    check_shift_time shift_time
    return shift_time.active_on?(date) && (shift_begins.nil? || shift_begins <= date) && (shift_ends.nil? || shift_ends > date)
  end

  scope :for_region, -> region {
    joins(:shift_territory).where(shift_territory: { region_id: region })
  }
  scope :active_on_day, -> date {
    #Todo: check day of week here
    where('shift_begins IS NULL OR shift_begins <= ? AND (shift_ends IS NULL OR shift_ends > ?)', date, date)
  }
  scope :for_shift_territories, -> shift_territories {
    where(shift_territory_id: shift_territories)
  }
  scope :can_be_taken_by, -> person {
    where(ignore_shift_territory: true).or(where(shift_territory_id: person.shift_territory_ids))
      .joins(:positions)
      .where(positions: { id: person.position_ids })
      .uniq
  }
  scope :for_groups, -> groups {
    joins(:shift_times).where(shift_times: { id: groups })
  }

  def can_be_taken_by?(person)
    if ignore_shift_territory or person.shift_territories.to_a.include?(shift_territory)
      (positions & person.positions).present?
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

    groups_by_id = shifts.flat_map(&:shift_times).reduce({}){|hash, group| hash[group.id] = group; hash }

    arr = Core::NestedHash.hash_hash_hash
    shifts.each do |shift|
      shift.shift_times.each do |group|
        arr[shift][group] = empties[group.period].dup
      end
    end

    arr = Scheduler::ShiftAssignment
      .where(shift_id: shifts.to_a, date: month..(month.at_end_of_month))
      .select('COUNT(id) AS count, shift_id, shift_time_id, date')
      .group(:shift_id, :shift_time_id, :date)
      .reduce(arr) do |hash, ass|
      shift = shifts_by_id[ass.shift_id]
      group = groups_by_id[ass.shift_time_id]
      if shift.nil? || group.nil?
        logger.warn "Got unknown shift back from query #{ass.shift_id} #{shifts_by_id.inspect}"
        next hash
      end

      if hash[shift][group][ass.date].nil?
        logger.warn "Got unknown date back from query #{ass.date} #{shift.shift_time_ids.inspect} #{hash.inspect}"
        next hash
      end

      hash[shift][group][ass.date] += 1
      hash
    end

    # make sure we put in shifts that don't show up at all
    shifts.each do |shift|
      shift.shift_times.each do |group|
        arr[shift][group] ||= days.dup
      end
    end

    arr
  end

  def self.shifts_available_by_day(shifts, month, include_partial: true)
    ret = shifts_taken_by_day(shifts, month)
    ret.each do |shift, group_dates|
      group_dates.each do |group, dates|
        dates.merge!(dates) do |date, count|
          shift.active_on_day?(date, group) && (count == 0 || (include_partial and count < shift.max_signups))
        end
      end
    end
    ret
  end

  def self.count_shifts_available_by_shift(shifts, month, include_partial: true, only_future: true)
    hash = shifts_available_by_day(shifts, month)
    hash.merge!(hash) do |shift, group_dates, _|
      group_dates.map do |group, dates|
        dates.map{|date, avail| (!only_future or date >= Date.current) && avail ? 1 : 0}
      end.flatten.sum
    end
  end

  def self.count_shifts_available_for_month(shifts, month, include_partial: true, only_future: true)
    count_shifts_available_by_shift(shifts, month).values.flatten.sum
  end

  def total_shifts_for_month(month)
    ((month.end_of_month)-month).to_i
  end

  def display_name
    "#{shift_times.first.try :region_id} - #{shift_territory.try(:abbrev)} #{name} - #{shift_times.map(&:name).join ', '}"
  end
end
