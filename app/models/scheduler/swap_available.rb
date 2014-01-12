class Scheduler::SwapAvailable
  def initialize(swap, invitee)
    @swap = swap
    @invitee = invitee
  end

  def save
    to_mail = []
    if @invitee.present?
      Scheduler::SwapMailer.swap_available(@swap, @invitee, @invitee).deliver
    else
      to_mail += Scheduler::NotificationSetting.people_to_notify_swap(@swap)
    end

    to_mail += Scheduler::NotificationSetting.admins_to_notify_swap(@swap, to_mail)
    to_mail.uniq.each do |recipient|
      Scheduler::SwapMailer.swap_available(@swap, nil, recipient).deliver
    end
  end
end