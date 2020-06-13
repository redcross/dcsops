class Scheduler::ShiftTime < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'
  has_and_belongs_to_many :shifts, -> {order(:ordinal)}, class_name: 'Scheduler::Shift'

  validates :start_offset, :end_offset, presence: true, numericality: true

  assignable_values_for :period do
    %w(daily weekly monthly)
  end

  attr_accessor :start_date

  def display_name
    "#{region_id} - #{name}"
  end

  def next_period_date
    raise unless start_date
    case self.period
    when 'daily' then start_date.tomorrow
    when 'weekly' then start_date.advance(weeks: 1)
    end
  end

  def next_group
    offset = self.start_offset
    group = self.class.where{(start_offset > offset) & (region_id == my{self.chapter_id}) & (period == self.period)}.order(:start_offset).first
    if group
      group.start_date = self.start_date
      return group
    end
    group = self.class.where{(region_id == my{self.chapter_id})}.order(:start_offset).first
    if group
      group.start_date = self.next_period_date if self.start_date
      group
    else
      nil
    end
  end

  def self.for_region(region)
    where(region: region)
  end

  def self.daily
    where{period == 'daily'}
  end

  def self.first_group(region, current_time=Time.zone.now)
    self.current_groups_for_region(region, current_time, daily).first || begin

      groups = daily.for_region(region).order(:start_offset).to_a

      groups.detect{start_offset <= current_time.seconds_since_midnight} || groups.first
    end
  end
  # Returns a date, group pairing of the count upcoming groups
  def self.next_groups(region, current_time=Time.zone.now)
    groups = for_region(region).order(:start_offset).to_a

    current_time = current_time.in_time_zone(region.time_zone)
    since_midnight = current_time.seconds_since_midnight

    groups.each do |group|
      group.check_offsets(current_time)
      unless group.start_date
        group.start_date = group.normalize_date current_time.to_date
        if group.end_offset < since_midnight
          group.start_date = group.next_period_date
        end
      end
    end

  end

  def unused

    current_group = first_group(region, current_time)

    return [] unless current_group

    ret = [{date: current_group.start_date, group: current_group}]
    while ret.count < count
      current_group = current_group.next_group
      ret << {date: current_group.start_date, group: current_group}
    end
    ret
  end

  def self.current_groups_for_region(region, current_time=Time.zone.now, scope=all)
    now = current_time.in_time_zone(region.time_zone)

    for_region(region).merge(scope).select{|group|
      group.check_offsets(now)
    }
  end

  def self.current_groups_in_array(groups, current_time)
    groups.select{ |grp| grp.check_offsets current_time }
  end

  def check_offsets(now)
    period_offsets(now).detect do |offset, date|
      check_offset offset, date
    end
  end

  def check_offset(current, date)
    if (start_offset <= current and current < end_offset) and active_on?(date)
      self.start_date = date
      true
    else
      false
    end
  end

  def period_offsets(now)
    case period
    when 'daily' then self.class.daily_offsets(now)
    when 'weekly' then self.class.weekly_offsets(now)
    when 'monthly' then self.class.monthly_offsets(now)
    end
  end

  def active_on? date
    case date.wday
    when 0 then active_sunday
    when 1 then active_monday
    when 2 then active_tuesday
    when 3 then active_wednesday
    when 4 then active_thursday
    when 5 then active_friday
    when 6 then active_saturday
    end
  end

  def self.daily_offsets(now)
    day_offset = now.seconds_since_midnight
    day_plus_offset = (day_offset + 1.day)

    { day_offset => now.to_date,
      day_plus_offset => now.to_date.yesterday }
  end

  def self.weekly_offsets(now)
    begin_of_week = now.to_date.at_beginning_of_week
    wday = (now.to_date - begin_of_week)

    week_offset = ((wday * 1.day) + now.seconds_since_midnight)
    week_plus_offset = (week_offset + 7.days)
    week_minus_offset = -(7.days-week_offset)

    { week_offset => begin_of_week,
      week_plus_offset => begin_of_week.advance(weeks: -1),
      week_minus_offset => begin_of_week.advance(weeks: 1) }
  end

  def self.monthly_offsets(now)
    begin_of_month = now.at_beginning_of_month.to_date
    month_offset = now.day
    month_plus_offset = now.day + now.months_since(1).at_end_of_month.day

    { month_offset => begin_of_month,
      month_plus_offset => begin_of_month.months_since(1) }
  end

  def normalize_date date
    case period
    when 'daily' then date
    when 'weekly' then date.at_beginning_of_week
    when 'monthly' then date.at_beginning_of_month
    end
  end
end
