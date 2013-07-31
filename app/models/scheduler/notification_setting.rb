class Scheduler::NotificationSetting < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person', foreign_key: :id

  #serialize :shift_notification_phones

  scope :needs_daily_email, ->chapter{ needs_daily(chapter, :email) }
  scope :needs_daily_sms, ->chapter{ needs_daily(chapter, :sms) }

  scope :needs_daily, -> chapter,method {
    now = chapter.time_zone.now
    midnight = now.at_beginning_of_day
    offset = now.seconds_since_midnight
    joins{person}.where{(person.chapter_id == chapter.id) & (__send__(:"#{method}_all_shifts_at") != nil) & (__send__(:"#{method}_all_shifts_at") <= offset) & ((__send__(:"last_all_shifts_#{method}") == nil) | (__send__(:"last_all_shifts_#{method}") < midnight))}.readonly(false)
  }

  before_create :set_calendar_api_token
  def set_calendar_api_token
    self.calendar_api_token ||= SecureRandom.hex 12
  end

  def self.people_to_notify_swap(shift_assignment)
    Roster::Person.joins{notification_setting}.where(scheduler_notification_settings: {email_swap_requested: true}).in_county(shift_assignment.shift.county).with_position(shift_assignment.shift.positions.to_a).to_a
  end

  def self.admins_to_notify_swap(shift_assignment, ignore=[])
    Roster::Person.joins{notification_setting}.in_county(shift_assignment.shift.county).where{(notification_setting.email_all_swaps == true) & (id.not_in ignore)}.to_a
  end
end
