class Scheduler::NotificationSetting < ApplicationRecord
  belongs_to :person, class_name: 'Roster::Person', foreign_key: :id

  #serialize :shift_notification_phones

  def self.needs_daily_email(region); needs_daily(region, :email); end
  def self.needs_daily_sms(region);   needs_daily(region, :sms); end
  def self.needs_daily_swap(region);  for_region(region).with_active_person.where{email_all_swaps_daily == true}; end

  def self.needs_daily region, method
    now = region.time_zone.now
    midnight = now.at_beginning_of_day
    offset = now.seconds_since_midnight
    for_region(region).with_active_person.where{(__send__(:"#{method}_all_shifts_at") != nil) & 
                                                  (__send__(:"#{method}_all_shifts_at") <= offset) & 
                                                  ( (__send__(:"last_all_shifts_#{method}") == nil) | 
                                                    (__send__(:"last_all_shifts_#{method}") < midnight)
                                                  )}.readonly(false)
  end

  def self.with_active_person
    joins{person}.where{person.vc_is_active == true}
  end

  def self.for_region region
    joins{person}.where{person.region_id == region.id}
  end

  before_create :set_calendar_api_token
  def set_calendar_api_token
    self.calendar_api_token ||= SecureRandom.hex 12
  end

  def self.people_to_notify_swap(shift_assignment)
    Roster::Person.joins{notification_setting}.where(notification_setting: {email_swap_requested: true}).in_shift_territory(shift_assignment.shift.shift_territory).with_position(shift_assignment.shift.positions.to_a).to_a
  end

  def self.admins_to_notify_swap(shift_assignment, ignore=[])
    Roster::Person.joins{notification_setting}.in_shift_territory(shift_assignment.shift.shift_territory).where{(notification_setting.email_all_swaps == true) & (id.not_in ignore)}.to_a
  end

  def allow_sms_at? time
    seconds = time.seconds_since_midnight
    (sms_only_after.nil? || (seconds >= sms_only_after)) and (sms_only_before.nil? || (seconds <= sms_only_before))
  end
end
