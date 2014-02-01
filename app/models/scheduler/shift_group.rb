class Scheduler::ShiftGroup < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  has_many :shifts, -> {order(:ordinal)}, class_name: 'Scheduler::Shift'

  validates_inclusion_of :period, in: %w(daily weekly monthly)
  validates :start_offset, :end_offset, presence: true, numericality: true

  attr_accessor :start_date

  def next_period_date
    raise unless start_date
    case self.period
    when 'daily' then start_date.tomorrow
    when 'weekly' then start_date.advance(weeks: 1)
    end
  end

  def next_group
    offset = self.start_offset
    group = self.class.where{(start_offset > offset) & (chapter_id == my{self.chapter_id}) & (period == self.period)}.order{start_offset}.first
    if group
      group.start_date = self.start_date
      return group
    end
    group = self.class.where{(chapter_id == my{self.chapter_id})}.order{start_offset}.first
    if group
      group.start_date = self.next_period_date if self.start_date
      group
    else
      nil
    end
  end

  # Returns a date, group pairing of the count upcoming groups
  def self.next_groups(chapter, count=2, current_time=Time.zone.now)
    current_time = current_time.in_time_zone(chapter.time_zone)

    current_group = self.current_groups_for_chapter(chapter, current_time).select{|grp| grp.period == 'daily'}.first

    ret = [{date: current_group.start_date, group: current_group}]
    while ret.count < count
      current_group = current_group.next_group
      ret << {date: current_group.start_date, group: current_group}
    end
    ret
  end

  def self.current_groups_for_chapter(chapter, current_time=Time.zone.now, scope=scoped)
    now = current_time.in_time_zone(chapter.time_zone)

    self.where(chapter_id: chapter).merge(scope).select{|group|
      group.check_offsets(now)
    }
  end

  def check_offsets(now)
    period_offsets(now).detect do |offset, date|
      check_offset offset, date
    end
  end

  def check_offset(current, date)
    if (start_offset <= current and current < end_offset) 
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
end
