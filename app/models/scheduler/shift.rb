class Scheduler::Shift < ActiveRecord::Base
  belongs_to :county, class_name: 'Roster::County'
  belongs_to :shift_category, class_name: 'Scheduler::ShiftCategory'

  has_and_belongs_to_many :positions, class_name: 'Roster::Position'
  has_and_belongs_to_many :shift_groups, class_name: 'Scheduler::ShiftGroup'
  has_many :shift_assignments

  validates :county, :shift_category, presence: true
  validates :max_signups, numericality: true, presence: true
  validates :min_desired_signups, numericality: true, presence: true
  validates_presence_of :name, :abbrev

  def check_shift_group group
    #unless shift_group_ids.include? group.id
    #  raise "That shift group does not belong to this shift"
    #end
  end

  def normalize_date date, shift_group
    case shift_group.period
    when 'daily' then date
    when 'weekly' then date.at_beginning_of_week
    when 'monthly' then date.at_beginning_of_month
    end
  end

  def can_sign_up_on_day(date, shift_group, num_assignments_on_day=nil)
    check_shift_group shift_group
    today = shift_group.chapter.time_zone.today

    return false if date < today and !allow_signup_in_past?(date, shift_group)
    return false unless active_on_day? date, shift_group
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

  def allow_signup_in_past?(date, shift_group)
    check_shift_group shift_group
    Scheduler::ShiftAssignment.new(date: date, shift: self, shift_group: shift_group).local_end_time >= shift_group.chapter.time_zone.now
  end

  def can_remove_on_day(date, shift_group)
    check_shift_group shift_group
    today = normalize_date shift_group.chapter.time_zone.today, shift_group
    advance = date - today
    (date >= today) and (signups_frozen_before.nil? || (date >= signups_frozen_before)) and (advance >= min_advance_signup) and (signups_available_before.nil? || (date <= signups_available_before))
  end

  def active_on_day?(date, shift_group)
    check_shift_group shift_group
    return shift_group.active_on?(date) && (shift_begins.nil? || shift_begins <= date) && (shift_ends.nil? || shift_ends > date)
  end

  scope :for_chapter, -> chapter {
    joins{county}.where{county.chapter_id == chapter}
  }
  scope :active_on_day, -> date {
    #Todo: check day of week here
    where{((shift_begins == nil) | (shift_begins <= date) & ((shift_ends == nil) | (shift_ends > date)))}
  }
  scope :for_counties, -> counties {
    where{county_id.in(counties)}
  }
  scope :can_be_taken_by, -> person {
    where{((ignore_county == true) | county_id.in(person.county_ids))}.joins{positions}.where{positions.id.in(person.position_ids)}.uniq
  }
  scope :for_groups, -> groups {
    joins{shift_groups}.where{shift_groups.id.in groups}
  }

  def can_be_taken_by?(person)
    if ignore_county or person.counties.to_a.include?(county)
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

    groups_by_id = shifts.flat_map(&:shift_groups).reduce({}){|hash, group| hash[group.id] = group; hash }

    arr = NestedHash.hash_hash_hash
    shifts.each do |shift|
      shift.shift_groups.each do |group|
        arr[shift][group] = empties[group.period].dup
      end
    end

    arr = Scheduler::ShiftAssignment.where{shift_id.in(shifts.to_a) & date.in(month..(month.at_end_of_month))}
                              .select{[count(id).as(:count), shift_id, shift_group_id, date]}.group{[shift_id, shift_group_id, date]}.reduce(arr) do |hash, ass|
      shift = shifts_by_id[ass.shift_id]
      group = groups_by_id[ass.shift_group_id]
      if shift.nil? || group.nil?
        raise "Got unknown shift back from query #{ass.shift_id} #{shifts_by_id.inspect}"
      end

      if hash[shift][group][ass.date].nil?
        logger.warn "Got unknown date back from query #{ass.date} #{shift.shift_group.period} #{hash.inspect}"
        next hash
      end

      hash[shift][group][ass.date] += 1
      hash
    end

    # make sure we put in shifts that don't show up at all
    shifts.each do |shift|
      shift.shift_groups.each do |group|
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

  def self.count_shifts_available_for_month(shifts, month, include_partial: true, only_future: true)
    shifts_available_by_day(shifts, month).map do |shift, dates|
      dates.map{|date, avail| (!only_future or date >= Date.current) && avail ? 1 : 0}.sum
    end.sum
  end

  def total_shifts_for_month(month)
    ((month.end_of_month)-month).to_i
  end

  def display_name
    "#{shift_groups.first.try :chapter_id} - #{shift_groups.map(&:name).join ', '} - #{county.try(:abbrev)} #{name}"
  end
end
