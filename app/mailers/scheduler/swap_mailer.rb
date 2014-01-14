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
    people = Roster::Person.in_county(shift_assignment.shift.county).with_position(shift_assignment.shift.positions).joins(:notification_setting).where{notification_setting.email_swap_requested eq true}
  end

  def swap_confirmed(old_shift, new_shift, recipients = nil)
    @from = old_shift
    @to = new_shift

    subject = "Shift Swap Confirmed for #{new_shift.date.to_s :dow_short} #{new_shift.shift.shift_group.name} #{new_shift.shift.name}"

    recipients ||= [@from.person, @to.person]

    tag :scheduler, :swap, :swap_confirmed
    mail to: recipients.map{|p| format_address p}, subject: subject
  end

  private

  def swap_invite_subject
    subject = "Shift Swap Requested for #{@shift.date.to_s :dow_short} #{@shift.shift.shift_group.name} #{@shift.shift.name}"
  end
end
