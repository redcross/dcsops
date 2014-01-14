class Scheduler::ShiftAssignment < ActiveRecord::Base
  class PersonAllowedToTakeShift < ActiveModel::Validator
    def validate(record)
      return false unless record.person and record.shift
      if record.person.counties.include?(record.shift.county) or record.shift.ignore_county
        allowed_positions = record.person.positions & record.shift.positions

        if allowed_positions.blank?
          record.errors[:shift] = "You are not allowed to take this shift. (Position)"
        end
      else
        record.errors[:shift] = "You are not allowed to take this shift. (County)"
      end
    end
  end

  class ShiftIsAvailable < ActiveModel::Validator
    def validate(record)
      return false unless record.shift and record.date
      assignments = record.shift.shift_assignments.where(date: record.date)
      if record.id
        assignments = assignments.where("scheduler_shift_assignments.id <> ?", record.id)
      end
      if record.swapping_from_id
        assignments = assignments.where("scheduler_shift_assignments.id <> ?", record.swapping_from_id)
      elsif record.shift.signups_frozen_before and record.date < record.shift.signups_frozen_before
        record.errors[:shift] = "Signups are frozen for this day"
      end
      unless record.shift.max_signups == 0 || assignments.count < record.shift.max_signups
        record.errors[:shift] = "This shift is not available"
      end
      if record.shift.shift_begins and record.shift.shift_begins > record.date
        record.errors[:shift] = "This shift has not started"
      end
      if record.shift.shift_ends and record.shift.shift_ends < record.date
        record.errors[:shift] = "This shift has ended and is no longer available for signup."
      end
    end
  end

  class PersonIsAvailable < ActiveModel::Validator
    def validate(record)
      return false unless record.shift and record.date and record.person
      assignments = Scheduler::ShiftAssignment.includes(:shift).where(shift: {shift_group_id: record.shift.shift_group}, date: record.date, person_id: record.person)
      if record.id
        assignments = assignments.where("scheduler_shift_assignments.id <> ?", record.id)
      end
      if assignments.exists?
        record.errors[:shift] = "You are already signed up for a shift in this group on this day."
      end
    end
  end

  class ShiftDateIsValid < ActiveModel::Validator
    def validate(record)
      return unless record.shift and record.shift.shift_group

      valid = case record.shift.shift_group.period
      when 'daily' then true
      when 'weekly' then record.date == record.date.at_beginning_of_week
      when 'monthly' then record.date.day == 1
      else true
      end
      if !valid 
        record.errors[:date] = "That is not a valid date for a #{record.shift.period} shift"
      end
    end
  end

  before_destroy :check_frozen_shift

  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :shift, class_name: 'Scheduler::Shift'
  belongs_to :notification_setting, foreign_key: 'person_id'

  validates :person, :shift, :date, presence: true
  validates_with PersonAllowedToTakeShift, ShiftIsAvailable, PersonIsAvailable, ShiftDateIsValid

  attr_accessor :swapping_from_id, :is_swapping_to

  scope :for_day, lambda {|day| where(date: day)}

  scope :for_active_groups, -> (groups) {
    joins{shift}.where{
      row(date, shift.shift_group_id).in(my{groups}.map{|group| row(group.start_date, group.id) })
    }
  }

  scope :for_chapter, -> (chapter) {
    joins{person}.where{person.chapter_id == chapter.id}
  }

  scope :for_shifts, -> (shifts) {
    where{shift_id.in(shifts)}
  }

  scope :for_counties, -> (counties) {
    joins{shift}.where{shift.county_id.in(counties)}
  }

  scope :for_groups, -> (groups) {
    joins{shift}.where{shift.shift_group_id.in(groups)}
  }

  scope :with_active_person, -> {
    joins{person}.where{person.vc_is_active == true}
  }
  
  scope :needs_email_invite, ->(chapter) {
    joins(:notification_setting).readonly(false)
    .with_active_person.for_chapter(chapter)
    .where(:email_invite_sent => false, :scheduler_notification_settings => {send_email_invites: true})
    .where('date > ?', chapter.time_zone.today)
  }
  
  scope :needs_email_reminder, ->(chapter){
    where(:email_reminder_sent => false)
    .joins{notification_setting}.where{notification_setting.email_advance_hours != nil}
    .with_active_person.for_chapter(chapter).readonly(false)
    .select{|ass|
      now = chapter.time_zone.now
      start = ass.local_start_time
      etime = ass.local_end_time
      ass.notification_setting.email_advance_hours and etime > now and (start - ass.notification_setting.email_advance_hours) < now
    }
  }

  scope :needs_sms_reminder, -> (chapter) {
    zone = chapter.time_zone
    now = chapter.time_zone.now

    where(:sms_reminder_sent => false)
    .joins{notification_setting}.where{notification_setting.sms_advance_hours != nil}
    .with_active_person.for_chapter(chapter).readonly(false)
    .select{|ass|
      ass.person.sms_addresses.present? # Can't send if we don't have any addresses
    }.select{|ass|
      start = ass.local_start_time
      etime = ass.local_end_time
      notifications_begin = (start - ass.notification_setting.sms_advance_hours)

      ass.notification_setting.sms_advance_hours and etime > now and notifications_begin < now
    }.select{|ass|
      seconds = now.seconds_since_midnight
      seconds >= ass.notification_setting.sms_only_after and seconds <= ass.notification_setting.sms_only_before
    }
  }

  scope :normalized_date_on_or_after, ->(time) {
    in_date = time.to_date
    joins{shift.shift_group}.where(<<-SQL)
    scheduler_shift_assignments.date >= (CASE scheduler_shift_groups.period
    WHEN 'daily' THEN '#{in_date}'::date
    WHEN 'weekly' THEN date_trunc('week', '#{in_date}'::date) - '7 days'::interval
    WHEN 'monthly' THEN date_trunc('month', '#{in_date}'::date) - '1 month'::interval
    ELSE NULL
    END)
    SQL
  }

  scope :starts_after, ->(time){
    start_date = time.to_date
    joins{shift.shift_group}.where{(date > start_date) | ((date == start_date) & (shift.shift_group.end_offset > time.in_time_zone.seconds_since_midnight))}
  }

  scope :available_for_swap, -> (chapter) {
    where{(available_for_swap==true)}.normalized_date_on_or_after(chapter.time_zone.today)
  }

  scope :includes_person_carriers, -> {
    includes{[person.home_phone_carrier, person.cell_phone_carrier, person.work_phone_carrier, person.alternate_phone_carrier, person.sms_phone_carrier]}
  }

  def local_start_time
    local_offset(date, shift.shift_group.start_offset)
  end

  def local_end_time
    local_offset(date, shift.shift_group.end_offset)
  end

  def swap_to(new_person)
    new_assignment = Scheduler::ShiftAssignment.new date: self.date, shift: self.shift, person: new_person, swapping_from_id: self.id
    self.is_swapping_to = true
    destroy! if new_assignment.save
    new_assignment
  end

  def check_frozen_shift
    if !is_swapping_to and shift.signups_frozen_before and shift.signups_frozen_before > date
      errors[:shift] = "Signups are frozen and cannot be edited"
      false
    else
      true
    end
  end

  private

  def local_offset(date, offset)
    #date.in_time_zone.at_beginning_of_day.advance( seconds: offset).iso8601

    beginning_of_day = date.in_time_zone(shift.shift_group.chapter.time_zone).at_beginning_of_day
    key = (shift.shift_group.period == 'monthly' ? :days : :seconds)
    offset_time = beginning_of_day.advance(key => offset)

    # advance counts every instant that elapses, not just calendar seconds.  so
    # when crossing DST you might end up one hour off in either direction even though
    # you just want "wall clock" time.  So if the offset of the two times is different, we
    # negate it.
    offset_time.advance seconds: (beginning_of_day.utc_offset - offset_time.utc_offset)
  end
end
