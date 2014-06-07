class Scheduler::ShiftSwap

  attr_reader :assignment, :new_assignment, :authorization_delegate

  def initialize(assignment, authorization_delegate)
    @assignment = assignment
    @authorization_delegate = authorization_delegate
  end

  def request_swap!(destination=nil)
    assignment.update_attribute :available_for_swap, true
    notify_swap_available(destination)
  end

  def cancel_swap!
    assignment.update_attribute :available_for_swap, false
  end

  def confirm_swap!(destination)
    success = perform_swap(destination)
      
    if success
      notify_swap_confirmed

      # Give it a chance to update the dispatch roster if this shift is coming soon...
      Scheduler::SendDispatchRosterJob.enqueue new_assignment.person.chapter, false if new_assignment.shift.dispatch_role
    end

    return success
  end

  def can_request?
    !assignment.available_for_swap
  end

  def can_confirm?
    assignment.available_for_swap
  end

  def error_message
    new_assignment.errors.full_messages.join
  end

  private

  def can_create?
    authorization_delegate.can? :create, new_assignment
  end

  def valid?
    new_assignment.valid?

    if !can_create?
      new_assignment.errors[:base] << 'You are not allowed to make this swap.'
    end

    if assignment.person == new_assignment.person
      new_assignment.errors[:person] << 'You can not swap a shift to yourself.'
    end

    new_assignment.errors.blank?
  end

  def perform_swap(destination)
    assignment.transaction do
      @new_assignment = Scheduler::ShiftAssignment.new date: assignment.date, 
                                                      shift: assignment.shift,
                                                shift_group: assignment.shift_group, 
                                                     person: destination, 
                                           swapping_from_id: assignment.id
      if valid? && new_assignment.save
        assignment.is_swapping_to = true
        assignment.destroy!
        true
      else
        false
      end
    end
  end

  def notify_swap_confirmed
    people = [assignment.person, new_assignment.person] + Scheduler::NotificationSetting.admins_to_notify_swap(assignment)
    people.uniq.each do |recipient|
      Scheduler::SwapMailer.swap_confirmed(assignment, new_assignment, recipient).deliver
    end
  end

  def notify_swap_available(destination)
    to_mail = []
    if destination
      Scheduler::SwapMailer.swap_available(assignment, destination, destination).deliver
    else
      to_mail = Scheduler::NotificationSetting.people_to_notify_swap(assignment)
    end

    to_mail += Scheduler::NotificationSetting.admins_to_notify_swap(assignment)

    to_mail.uniq.each do |recipient|
      Scheduler::SwapMailer.swap_available(assignment, nil, recipient).deliver
    end
  end

end
