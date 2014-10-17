class Scheduler::SendRemindersJob

  def self.enqueue
    Roster::Chapter.all.each do |chapter|
      new(chapter.id).perform
    end
  end

  def initialize chapter_id
    @chapter_id = chapter_id
  end

  def perform
    send_shift_reminder :email_invite
    send_shift_reminder :email_reminder
    send_shift_reminder :sms_reminder
    send_daily :sms
    send_daily :email
  end

  def send_shift_reminder type
    Scheduler::ShiftAssignment.send("needs_#{type}", chapter).each do |assignment|
      send_reminder type, assignment.person, assignment
      assignment.update_attribute("#{type}_sent", true) # don't fail!
    end
  end

  def send_daily type
    Scheduler::NotificationSetting.send("needs_daily_#{type}", chapter).each do |setting|
      send_reminder "daily_#{type}_reminder", setting.person, setting
      setting.update_attribute("last_all_shifts_#{type}", chapter.time_zone.today) # don't fail!
    end
  end

  # Need to capture any errors with delivery and log them with the person.
  def send_reminder mailer, person, *args
    Scheduler::RemindersMailer.send(mailer, *args).deliver
  rescue => e
    Raven.capture e
  end

  def chapter
    @chapter ||= Roster::Chapter.find @chapter_id
  end
end