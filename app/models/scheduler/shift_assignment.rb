class Scheduler::ShiftAssignment < ApplicationRecord
  class PersonAllowedToTakeShift < ActiveModel::Validator
    def validate(record)
      return false unless record.person and record.shift
      if record.person.shift_territories.include?(record.shift.shift_territory) or record.shift.ignore_shift_territory
        allowed_positions = record.person.positions & record.shift.positions

        if allowed_positions.blank?
          record.errors[:shift] = "You are not allowed to take this shift. (Position)"
        end
      else
        record.errors[:shift] = "You are not allowed to take this shift. (Shift Territory)"
      end
    end
  end

  class ShiftIsAvailable < ActiveModel::Validator
    def validate(record)
      return false unless record.shift and record.date and record.shift_time
      assignments = record.shift.shift_assignments.where(date: record.date, shift_time_id: record.shift_time_id)
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
      unless record.shift.active_on_day? record.date, record.shift_time
        record.errors[:shift] = "This shift does not happen on this day."
      end
    end
  end

  class PersonIsAvailable < ActiveModel::Validator
    def validate(record)
      return false unless record.shift and record.date and record.person
      return true unless record.shift.exclusive
      assignments = Scheduler::ShiftAssignment.includes(:shift).where(scheduler_shifts: {exclusive: true}, shift_time_id: record.shift_time, date: record.date, person_id: record.person)
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
      return unless record.shift and record.shift_time

      valid = case record.shift_time.period
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

  class ShiftTimeIsValid < ActiveModel::Validator
    def validate(record)
      return unless record.shift and record.shift.shift_time

      valid = record.shift.shift_time_ids.include? record.shift_time_id
      if !valid 
        record.errors[:shift_time] = "That is not a valid group for this shift"
      end
    end
  end

  before_destroy :check_frozen_shift

  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :shift, class_name: 'Scheduler::Shift'
  belongs_to :shift_time, class_name: 'Scheduler::ShiftTime'
  belongs_to :notification_setting, foreign_key: 'person_id'

  validates :person, :shift, :shift_time, :date, presence: true
  validates_with PersonAllowedToTakeShift, ShiftIsAvailable, PersonIsAvailable, ShiftDateIsValid

  attr_accessor :swapping_from_id, :is_swapping_to

  scope :for_day, lambda {|day| where(date: day)}

  scope :for_active_groups, -> (groups) {
    groups=groups.map{|group| {start_date: group.start_date, id: group.id}}.uniq
    for_active_groups_raw groups
  }

  def self.for_active_groups_raw tuples
    # NOTE: Squeel migration note:
    # I'm not sure who provides the `row` method; it doesn't seem to exist in Squeel.
    # I'm going to raise an exception here any future callers will know they
    # need to deal with it, and hopefully they'll be in a better position to
    # figure out the original intent.
    raise("Incomplete Squeel migration")
    where{
      row(date, shift_time_id).in(tuples.map{|hash| row(hash[:start_date], hash[:id]) })
    }
  end

  scope :for_region, -> (region) {
    joins(:person).where(person: { region_id: region})
  }

  scope :for_shifts, -> (shifts) {
    where(shift_id: shifts)
  }

  scope :for_shift_territories, -> (shift_territories) {
    joins(:shift).where{shift.shift_territory_id.in(shift_territories)}
  }

  scope :for_groups, -> (groups) {
    where(shift_time_id: groups)

  scope :with_active_person, -> {
    joins(:person).where(person: { vc_is_active: true })
  }
  
  def self.needs_email_invite region
    joins(:notification_setting).readonly(false)
    .with_active_person.for_region(region)
    .where(:email_invite_sent => false, :scheduler_notification_settings => {send_email_invites: true})
    .where('date > ?', region.time_zone.today)
  end

  def self.needs_reminder region, type
    where(:"#{type}_reminder_sent" => false)
    .joins(:notification_setting)
    .where.not(notification_setting.__send__("#{type}_advance_hours") => nil)
    .with_active_person.for_region(region).readonly(false).preload(:notification_setting, shift_time: :region)
    .select{|ass|
      now = region.time_zone.now
      start = ass.local_start_time
      etime = ass.local_end_time
      etime > now and (start - ass.notification_setting.send("#{type}_advance_hours")) < now
    }
  end
  
  def self.needs_email_reminder region
    needs_reminder(region, :email)
  end

  def self.needs_sms_reminder region
    now = region.time_zone.now

    needs_reminder(region, :sms)
    .select{|ass|
      ass.person.sms_addresses.present? # Can't send if we don't have any addresses
    }.select{|ass| ass.notification_setting.allow_sms_at? now }
  end

  def self.normalized_date_sql time
    in_date = time.to_date
    "(CASE scheduler_shift_times.period
    WHEN 'daily' THEN '#{in_date}'::date
    WHEN 'weekly' THEN date_trunc('week', '#{in_date}'::date) - '7 days'::interval
    WHEN 'monthly' THEN date_trunc('month', '#{in_date}'::date) - '1 month'::interval
    ELSE NULL
    END)"
  end

  def self.normalized_date_between date_first, date_last
    joins(:shift_time).where("date BETWEEN #{normalized_date_sql date_first} AND #{normalized_date_sql date_last}")
  end

  def self.normalized_date_on_or_after time
    joins(:shift_time).where("scheduler_shift_assignments.date >= #{normalized_date_sql time}")
  end

  def self.ordered_shifts region
    joins(:person).where(person: {region_id: region)).readonly(false).joins(:shift, :shift_time).order('shift.ordinal', 'shift_time.start_offset', 'person_id').preload(:person, :shift, :shift_time, shift: :shift_territory)
  end

  def self.todays_shifts_with_notes region
    ordered_shifts(region).where{(note != nil) & (date == Date.current)}
  end

  scope :starts_after, ->(time){
    start_date = time.to_date
    joins(:shift_time).where('date > ?', start_date).or(where(date: start_date).where('shift_time.end_offset > ?', time.in_time_zone.seconds_since_midnight))
  }

  scope :available_for_swap, -> (region) {
    where(available_for_swap: true).normalized_date_on_or_after(region.time_zone.today)
  }

  scope :includes_person_carriers, -> {
    includes(person: [:home_phone_carrier, :cell_phone_carrier, :work_phone_carrier, :alternate_phone_carrier, :sms_phone_carrier])
  }



  def local_start_time
    key = (shift_time.period == 'monthly' ? :days : :seconds)
    shift_time_calculator.local_offset(date, key => shift_time.start_offset)
  end

  def local_end_time
    key = (shift_time.period == 'monthly' ? :days : :seconds)
    shift_time_calculator.local_offset(date, key => shift_time.end_offset)
  end

  def check_frozen_shift
    if !is_swapping_to and shift.signups_frozen_before and shift.signups_frozen_before > date
      errors[:shift] = "Signups are frozen and cannot be edited"
      throw(:abort)
    end
  end

  def completed?
    local_end_time < Time.now
  end

  private

  def shift_time_calculator
    @_calculator ||= Scheduler::ShiftTimeCalculator.new(shift_time.region.time_zone)
  end

end
