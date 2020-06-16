class Scheduler::NotificationSetting < ApplicationRecord
  belongs_to :person, class_name: 'Roster::Person', foreign_key: :id

  #serialize :shift_notification_phones

  def self.needs_daily_email(chapter); needs_daily(chapter, :email); end
  def self.needs_daily_sms(chapter);   needs_daily(chapter, :sms); end
  def self.needs_daily_swap(chapter);  for_chapter(chapter).with_active_person.where(email_all_swaps_daily: true); end

  def self.needs_daily chapter, method
    now = chapter.time_zone.now
    midnight = now.at_beginning_of_day
    offset = now.seconds_since_midnight
    for_chapter(chapter).with_active_person
      .where("#{__send__(:"#{method}_all_shifts_at")} IS NOT NULL")
      .where("#{__send__(:"#{method}_all_shifts_at")} <= ?", offset)
      .where("#{__send__(:"last_all_shifts_#{method}")} IS NULL OR #{__send__(:"last_all_shifts_#{method}")} < ?", midnight)
      .readonly(false)
  end

  def self.with_active_person
    joins(:person).where(person: { vc_is_active: true })
  end

  def self.for_chapter chapter
    joins(:person).where(person: { chapter_id: chapter.id })
  end

  before_create :set_calendar_api_token
  def set_calendar_api_token
    self.calendar_api_token ||= SecureRandom.hex 12
  end

  def self.people_to_notify_swap(shift_assignment)
    Roster::Person.joins(:notification_setting).where(notification_setting: {email_swap_requested: true}).in_county(shift_assignment.shift.county).with_position(shift_assignment.shift.positions.to_a).to_a
  end

  def self.admins_to_notify_swap(shift_assignment, ignore=[])
    Roster::Person.joins(:notification_setting).in_county(shift_assignment.shift.county)
      .where(notification_setting: { email_all_swaps: true })
      .where.not(id: ignore).to_a
  end

  def allow_sms_at? time
    seconds = time.seconds_since_midnight
    (sms_only_after.nil? || (seconds >= sms_only_after)) and (sms_only_before.nil? || (seconds <= sms_only_before))
  end
end
