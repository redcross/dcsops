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
      return false unless record.shift and record.date and record.shift_group
      assignments = record.shift.shift_assignments.where(date: record.date, shift_group_id: record.shift_group_id)
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
      unless record.shift.active_on_day? record.date, record.shift_group
        record.errors[:shift] = "This shift does not happen on this day."
      end
    end
  end

  class PersonIsAvailable < ActiveModel::Validator
    def validate(record)
      return false unless record.shift and record.date and record.person
      return true unless record.shift.exclusive
      assignments = Scheduler::ShiftAssignment.includes(:shift).where(shift: {exclusive: true}, shift_group_id: record.shift_group, date: record.date, person_id: record.person)
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
      return unless record.shift and record.shift_group

      valid = case record.shift_group.period
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

  class ShiftGroupIsValid < ActiveModel::Validator
    def validate(record)
      return unless record.shift and record.shift.shift_group

      valid = record.shift.shift_group_ids.include? record.shift_group_id
      if !valid 
        record.errors[:shift_group] = "That is not a valid group for this shift"
      end
    end
  end

  before_destroy :check_frozen_shift

  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :shift, class_name: 'Scheduler::Shift'
  belongs_to :shift_group, class_name: 'Scheduler::ShiftGroup'
  belongs_to :notification_setting, foreign_key: 'person_id'

  validates :person, :shift, :shift_group, :date, presence: true
  validates_with PersonAllowedToTakeShift, ShiftIsAvailable, PersonIsAvailable, ShiftDateIsValid

  attr_accessor :swapping_from_id, :is_swapping_to

  scope :for_day, lambda {|day| where(date: day)}

  scope :for_active_groups, -> (groups) {
    groups=groups.map{|group| {start_date: group.start_date, id: group.id}}.uniq
    for_active_groups_raw groups
  }

  def self.for_active_groups_raw tuples
    where{
      row(date, shift_group_id).in(tuples.map{|hash| row(hash[:start_date], hash[:id]) })
    }
  end

  scope :for_chapter, -> (chapter) {
    joins{person}.where{person.chapter_id == chapter}
  }

  scope :for_shifts, -> (shifts) {
    where{shift_id.in(shifts)}
  }

  scope :for_counties, -> (counties) {
    joins{shift}.where{shift.county_id.in(counties)}
  }

  scope :for_groups, -> (groups) {
    where{shift_group_id.in(groups)}
  }

  scope :with_active_person, -> {
    joins{person}.where{person.vc_is_active == true}
  }
  
  def self.needs_email_invite chapter
    joins(:notification_setting).readonly(false)
    .with_active_person.for_chapter(chapter)
    .where(:email_invite_sent => false, :scheduler_notification_settings => {send_email_invites: true})
    .where('date > ?', chapter.time_zone.today)
  end

  def self.needs_reminder chapter, type
    where(:"#{type}_reminder_sent" => false)
    .joins{notification_setting}.where{notification_setting.__send__("#{type}_advance_hours") != nil}
    .with_active_person.for_chapter(chapter).readonly(false).includes{notification_setting}
    .select{|ass|
      now = chapter.time_zone.now
      start = ass.local_start_time
      etime = ass.local_end_time
      etime > now and (start - ass.notification_setting.send("#{type}_advance_hours")) < now
    }
  end
  
  def self.needs_email_reminder chapter
    needs_reminder(chapter, :email)
  end

  def self.needs_sms_reminder chapter
    now = chapter.time_zone.now

    needs_reminder(chapter, :sms)
    .select{|ass|
      ass.person.sms_addresses.present? # Can't send if we don't have any addresses
    }.select{|ass| ass.notification_setting.allow_sms_at? now }
  end

  def self.normalized_date_on_or_after time
    in_date = time.to_date
    joins{shift_group}.where(<<-SQL)
    scheduler_shift_assignments.date >= (CASE scheduler_shift_groups.period
    WHEN 'daily' THEN '#{in_date}'::date
    WHEN 'weekly' THEN date_trunc('week', '#{in_date}'::date) - '7 days'::interval
    WHEN 'monthly' THEN date_trunc('month', '#{in_date}'::date) - '1 month'::interval
    ELSE NULL
    END)
    SQL
  end

  scope :starts_after, ->(time){
    start_date = time.to_date
    joins{shift_group}.where{(date > start_date) | ((date == start_date) & (shift_group.end_offset > time.in_time_zone.seconds_since_midnight))}
  }

  scope :available_for_swap, -> (chapter) {
    where{(available_for_swap==true)}.normalized_date_on_or_after(chapter.time_zone.today)
  }

  scope :includes_person_carriers, -> {
    includes{[person.home_phone_carrier, person.cell_phone_carrier, person.work_phone_carrier, person.alternate_phone_carrier, person.sms_phone_carrier]}
  }

  def local_start_time
    local_offset(date, shift_group.start_offset)
  end

  def local_end_time
    local_offset(date, shift_group.end_offset)
  end

  def check_frozen_shift
    if !is_swapping_to and shift.signups_frozen_before and shift.signups_frozen_before > date
      errors[:shift] = "Signups are frozen and cannot be edited"
      false
    else
      true
    end
  end

  def completed?
    local_end_time < Time.now
  end

  private

  def local_offset(date, offset)
    #date.in_time_zone.at_beginning_of_day.advance( seconds: offset).iso8601

    beginning_of_day = date.in_time_zone(shift_group.chapter.time_zone).at_beginning_of_day
    key = (shift_group.period == 'monthly' ? :days : :seconds)
    offset_time = beginning_of_day.advance(key => offset)

    # advance counts every instant that elapses, not just calendar seconds.  so
    # when crossing DST you might end up one hour off in either direction even though
    # you just want "wall clock" time.  So if the offset of the two times is different, we
    # negate it.
    offset_time.advance seconds: (beginning_of_day.utc_offset - offset_time.utc_offset)
  end
end
