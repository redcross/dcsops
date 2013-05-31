class Scheduler::ShiftGroup < ActiveRecord::Base
  belongs_to :chapter, class_name: 'Roster::Chapter'
  has_many :shifts, -> {order(:ordinal)}

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
    group = self.class.where{(start_offset > offset) & (chapter_id == self.chapter_id) & (period == self.period)}.order{start_offset}.first
    if group
      group.start_date = self.start_date
      return group
    end
    group = self.class.where{(chapter_id == self.chapter_id)}.order{start_offset}.first
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


  def self.current_groups_for_chapter(chapter, current_time=Time.zone.now)
    now = current_time.in_time_zone(chapter.time_zone)

    self.where(chapter_id: chapter).select{|group|
      if group.period == 'daily'
        day_offset = now.seconds_since_midnight
        day_plus_offset = day_offset + 1.day.to_i

        check_offset(group.start_offset, group.end_offset, day_offset, day_plus_offset) do |is_plus|
          group.start_date = is_plus ? now.to_date.yesterday : now.to_date
        end
      elsif group.period == 'weekly'
        week_offset = (now.wday * 1.day.to_i) + now.seconds_since_midnight
        week_plus_offset = week_offset + 7.days.to_i

        check_offset(group.start_offset, group.end_offset, week_offset, week_plus_offset) do |is_plus|
          group.start_date = is_plus ? now.to_date.at_beginning_of_week.advance(weeks: -1) : now.to_date.at_beginning_of_week
        end
      elsif group.period == 'monthly'
        month_offset = now.day
        month_plus_offset = now.day + now.months_since(1).at_end_of_month.day

        check_offset(group.start_offset, group.end_offset, month_offset, month_plus_offset) do |is_plus|
          group.start_date = is_plus ? now.months_since(1).at_beginning_of_month : now.at_beginning_of_month
        end
      end
    }
  end

  def self.check_offset(start_offset, end_offset, current, current_plus)
    if (start_offset <= current and current < end_offset) 
      yield false
      true
    elsif (start_offset <= current_plus and current_plus < end_offset)
      yield true
      true
    else
      false
    end
  end
end
