class Scheduler::SwapConfirmed
  def initialize(old, new)
    @old = old
    @new = new
  end

  def save
    Scheduler::SwapMailer.swap_confirmed(@old, @new).deliver
    Scheduler::NotificationSetting.admins_to_notify_swap(@old).each do |recipient|
      Scheduler::SwapMailer.swap_confirmed(@old, @new, recipient).deliver
    end
  end
end