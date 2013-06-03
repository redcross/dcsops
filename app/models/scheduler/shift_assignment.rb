class Scheduler::ShiftAssignment < ActiveRecord::Base
  class PersonAllowedToTakeShift < ActiveModel::Validator
    def validate(record)
      return false unless record.person and record.shift
      if record.person.counties.include? record.shift.county
        allowed_positions = record.person.positions & record.shift.positions

        if allowed_positions.blank?
          record.errors[:shift] = "You are not allowed to take this shift."
        end
      else
        record.errors[:shift] = "You are not allowed to take this shift."
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
      assignments = Scheduler::ShiftAssignment.includes(:shift).where(scheduler_shifts: {shift_group_id: record.shift.shift_group}, date: record.date, person_id: record.person)
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
  scope :needs_email_invite, ->{includes(:notification_setting).where(:email_invite_sent => false, :scheduler_notification_settings => {send_email_invites: true}).where('date > ?', Date.current)}
  scope :needs_email_reminder, ->(chapter){
    includes(:notification_setting).where(:email_reminder_sent => false)
    .where("scheduler_notification_settings.email_advance_hours is not null").references(:scheduler_notification_settings)
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
    includes(:notification_setting).where(:sms_reminder_sent => false)
    .where("scheduler_notification_settings.sms_advance_hours is not null").references(:scheduler_notification_settings)
    .select{|ass|
      start = ass.local_start_time
      etime = ass.local_end_time
      notifications_begin = (start - ass.notification_setting.sms_advance_hours)

      ass.notification_setting.sms_advance_hours and etime > now and notifications_begin < now
    }.select{|ass|
      seconds = now.seconds_since_midnight
      seconds >= ass.notification_setting.sms_only_after and seconds <= ass.notification_setting.sms_only_before
    }
  }

  scope :starts_after, ->(time){
    joins(:shift => :shift_group).references(:shift => :shift_group).where('date > ? or (date=? AND scheduler_shift_groups.end_offset > ?)', time.to_date, time.to_date, time.in_time_zone.seconds_since_midnight)
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

    beginning_of_day = date.in_time_zone(person.chapter.time_zone).at_beginning_of_day
    offset_time = beginning_of_day.advance seconds: offset

    # advance counts every instant that elapses, not just calendar seconds.  so
    # when crossing DST you might end up one hour off in either direction even though
    # you just want "wall clock" time.  So if the offset of the two times is different, we
    # negate it.
    offset_time.advance seconds: (beginning_of_day.utc_offset - offset_time.utc_offset)
  end
end
