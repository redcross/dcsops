class Scheduler::SwapMailer < ActionMailer::Base
  include MailerCommon

  default from: "DAT Scheduling <scheduling@dcsops.org>"

  def swap_available(shift, invitee, recipient)
    @person = invitee
    @recipient = recipient
    @shift = shift

    tag :scheduler, :swap, :swap_available
    mail to: format_address(@recipient), subject: swap_invite_subject, template_name: 'swap_invite'
  end

  def swap_request_notify(shift_assignment)
    people = Roster::Person.in_shift_territory(shift_assignment.shift.shift_territory)
      .with_position(shift_assignment.shift.positions)
      .joins(:notification_setting)
      .where(scheduler_notification_settings: { email_swap_requested: true })
  end

  def swap_confirmed(old_shift, new_shift, recipient)
    @from = old_shift
    @to = new_shift

    subject = "Shift Swap Confirmed for #{new_shift.date.to_s :dow_short} #{new_shift.shift_time.name} #{new_shift.shift.name}"

    tag :scheduler, :swap, :swap_confirmed
    mail to: format_address(recipient), subject: subject
  end

  private

  def swap_invite_subject
    subject = "Shift Swap Requested for #{@shift.date.to_s :dow_short} #{@shift.shift_time.name} #{@shift.shift.name}"
  end
end
