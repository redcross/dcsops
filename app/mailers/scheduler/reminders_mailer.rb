class Scheduler::RemindersMailer < ActionMailer::Base
  include MailerCommon
  default from: "DAT Scheduling <scheduling@arcbadat.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #
  def email_invite(assignment)
    @assignment = assignment

    tag :scheduler, :reminders, :email_invite
    mail to: format_address(assignment.person), subject: "#{assignment.shift.name} on #{assignment.date.strftime("%b %d")}" do |format|
      format.html
      format.ics
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_reminder.subject
  #
  def email_reminder(assignment)
    @assignment = assignment

    tag :scheduler, :reminders, :email_reminder
    mail to: format_address(assignment.person), subject: "#{assignment.shift.name} on #{assignment.date.strftime("%b %d")}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.sms_reminder.subject
  #
  def sms_reminder(assignment)
    @assignment = assignment

    sms!
    tag :scheduler, :reminders, :sms_reminder, :sms
    mail to: assignment.person.sms_addresses, subject: ""
  end

  def daily_email_reminder(setting)
    now = setting.person.chapter.time_zone.now
    prepare_reminders(setting)

    tag :scheduler, :reminders, :daily_email_reminder
    mail to: format_address(setting.person), subject: "DAT Shifts for #{now.strftime("%b %d")}"
  end

  def daily_sms_reminder(setting)
    now = setting.person.chapter.time_zone.now
    prepare_reminders(setting)

    sms!
    tag :scheduler, :reminders, :daily_sms_reminder, :sms
    mail to: setting.person.sms_addresses, subject: ""
  end

  def daily_swap_reminder(setting)
    now = setting.person.chapter.time_zone.now
    prepare_swap_groups(setting)
    if @swap_groups.present?
      tag :scheduler, :reminders, :daily_swap_reminder
      mail to: format_address(setting.person), subject: "Daily Shift Swaps Reminder for #{now.strftime("%b %d")}"
    else
      self.message.perform_deliveries = false
    end
  end

  private
  def prepare_reminders(setting)
    @setting = setting
    @groups = Scheduler::ShiftGroup.current_groups_for_chapter(setting.person.chapter)
    @groups = Scheduler::ShiftGroup.next_groups(setting.person.chapter)

    counties = setting.person.primary_county

    @groups = @groups.uniq.reduce({}) do |hash, grphash|
      hash.tap{|h|
        h[grphash] = grphash[:group].shifts.where(county_id: counties).order(:ordinal).to_a
      }
    end
  end
  def prepare_swap_groups(setting)
    @setting = setting

    counties = setting.person.primary_county

    @swap_groups = Scheduler::ShiftAssignment.includes{shift.county}.where{(shift.county_id.in(counties))}.available_for_swap(setting.person.chapter).reduce({}) do |hash, ass|
      hash[ass.shift.county] ||= []
      hash[ass.shift.county] << ass
      hash
    end

  end
  def item
    @assignment
  end
  def shift_lead
    @shift_lead ||= Scheduler::ShiftAssignment.includes(:shift)
        .where(date: item.date)
        .where{{shift => {shift_group_id => my{item.shift.shift_group_id}, county_id => my{item.shift.county_id}}}}
        .where{shift.dispatch_role != nil}.order("scheduler_shifts.dispatch_role asc")
        .first
  end
  def other_assignments
    Scheduler::ShiftAssignment.includes(:shift).joins(:shift).where(date: item.date, shift: {shift_group_id: item.shift.shift_group, county_id: item.shift.county}).references(:shift).order('scheduler_shifts.ordinal')
  end
  def assignments_for_date_shift(the_date, shift)
    Scheduler::ShiftAssignment.where{shift_id.in(shift.id) & (date == the_date)}
  end

  def format_person(person, count=2)
    numbers = person.phone_order.first(count).map{|ph| "#{ph[:number]} (#{ph[:label][0]})"}.join(" ")
    "#{person.full_name} #{numbers}"
  end


  helper_method :item, :shift_lead, :other_assignments, :assignments_for_date_shift, :format_person
end
