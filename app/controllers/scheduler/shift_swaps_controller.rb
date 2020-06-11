class Scheduler::ShiftSwapsController < Scheduler::BaseController
  authorize_resource class_name: 'Scheduler::ShiftAssignment'
  inherit_resources
  defaults singleton: true, class_name: 'Scheduler::ShiftSwap'
  belongs_to :shift_assignment, class_name: 'Scheduler::ShiftAssignment'

  custom_actions resource: :confirm

  def swap
    @swap = 
    if params[:is_swap] && @swap.can_request?
      @swap.request_swap!(swap_to_person)

    elsif params[:accept_swap] && @swap.can_confirm?
      

    elsif params[:cancel_swap] && @swap.can_confirm?
      @swap.cancel_swap!
    end
    show!
  end

  before_action :check_can_confirm, only: [:destroy, :show, :confirm]
  before_action :check_can_request, only: [:new, :create]

  def new

  end

  def create
    resource.request_swap! swap_to_person
    redirect_to resource_path(resource.assignment)
  end

  def destroy
    resource.cancel_swap!
    flash[:info] = "The shift swap has been cancelled."
    redirect_to parent_path
  end

  def show

  end

  def confirm
    if resource.confirm_swap! swap_to_other_person
      flash[:info] = 'Shift successfully swapped.'
      redirect_to new_scheduler_shift_assignment_shift_swap_path(resource.new_assignment)
    else
      flash[:error] = resource.error_message
      redirect_to resource_path
    end
  end

  protected

  def check_can_request
    if !resource.can_request?
      if resource.can_confirm?
        redirect_to resource_path
      else
        redirect_to parent_path
      end
    end
  end

  def check_can_confirm
    if !resource.can_confirm?
      redirect_to new_resource_path
    end
  end

  def resource
    @swap ||= Scheduler::ShiftSwap.new parent, self
  end

  def swap_to_person
    Roster::Person.find_by(id: params[:swap_to_id])
  end

  def swap_to_other_person
    if can_swap_to_others?
      swap_to_person
    else
      current_user
    end
  end

  helper_method :can_swap_to_others?
  def can_swap_to_others?
    # This should be true where we have given :manage permissions to specific assignments
    # The swap code will check if this is legal for a given swap later
    can? :swap_to_others, Scheduler::ShiftAssignment
  end

end