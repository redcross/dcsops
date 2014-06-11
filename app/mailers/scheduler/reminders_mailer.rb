class Scheduler::RemindersMailer < ActionMailer::Base
  include MailerCommon
  include Exposure

  default from: "DAT Scheduling <scheduling@dcsops.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #
  def email_invite(assignment)
    @assignment = assignment

    tag :scheduler, :reminders, :email_invite
    mail to: format_address(assignment.person), subject: shift_subject do |format|
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
    mail to: format_address(assignment.person), subject: shift_subject
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
  use_sms_relay :sms_reminder, :daily_sms_reminder

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
  def shift_subject
    "#{@assignment.shift.name} on #{@assignment.date.strftime("%b %d")}"
  end

  def prepare_reminders(setting)
    @setting = setting
    @groups = Scheduler::ShiftGroup.next_groups(setting.person.chapter)

    counties = setting.person.primary_county

    @groups = @groups.uniq.reduce({}) do |hash, grphash|
      hash.tap{|h|
        h[grphash] = grphash[:group].shifts.where(county_id: counties).order(:ordinal).active_on_day(setting.person.chapter.time_zone.today).to_a
      }
    end
  end

  def prepare_swap_groups(setting)
    @setting = setting

    counties = setting.person.primary_county

    @swap_groups = Scheduler::ShiftAssignment.includes{shift.county}.for_counties(counties)
                  .available_for_swap(setting.person.chapter).group_by{|ass| ass.shift.county }
  end

  def item
    @assignment
  end

  expose(:related_shifts) {Scheduler::ShiftAssignment.for_day(item.date).for_counties(item.shift.county).for_groups(item.shift_group_id).includes{shift}}

  def shift_lead
    @shift_lead ||= related_shifts.order{shift.ordinal}.first
  end

  def other_assignments
    related_shifts.order{shift.ordinal}
  end

  def assignments_for_date_shift_group(date, shift, group)
    Scheduler::ShiftAssignment.for_shifts(shift).for_day(date).for_groups(group)
  end

  def format_person(person, count=2)
    numbers = person.phone_order.first(count).map{|ph| "#{ph[:number]} (#{ph[:label][0]})"}.join(" ")
    "#{person.full_name} #{numbers}"
  end


  helper_method :item, :shift_lead, :other_assignments, :assignments_for_date_shift_group, :format_person
end
