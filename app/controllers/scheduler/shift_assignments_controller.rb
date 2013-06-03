class Scheduler::ShiftAssignmentsController < Scheduler::BaseController
  inherit_resources
  load_and_authorize_resource class_name: 'Scheduler::ShiftAssignment'

  respond_to :html, :json
  respond_to :ics, only: [:index]

  has_scope :show_shifts, default: 'mine', only: [:index] do |controller, scope, arg|
    new_scope = case arg
    when 'mine'
      if controller.params[:person_id]
        authorize! :read, Scheduler::ShiftAssignment.new(person_id: controller.params[:person_id])
        scope.where{person_id == my{controller.params[:person_id]}}
      else
        scope.where{person_id == my{controller.current_user.id}}
      end
    when 'all'
      controller.authorize! :read_all_shifts, Scheduler::ShiftAssignment
      scope
    end
  end

  has_scope :for_county do |controller, scope, arg|
    joins{shift}.where{shift.county_id.in(arg)}
  end

  def swap
    if params[:is_swap]
      resource.available_for_swap = true
      resource.save!
      mailed_people = []

      if params[:swap_to_id].present?
        Scheduler::SwapMailer.swap_invite(resource, Roster::Person.find( params[:swap_to_id])).deliver
        to_mail = []
      else
        to_mail = Scheduler::NotificationSetting.people_to_notify_swap(resource)
        to_mail.each do |recipient|
          Scheduler::SwapMailer.swap_available(resource, recipient).deliver
        end
      end

      to_mail = Scheduler::NotificationSetting.admins_to_notify_swap(resource, to_mail)
      to_mail.each do |recipient|
        Scheduler::SwapMailer.swap_available(resource, recipient).deliver
      end


    elsif params[:accept_swap] and resource.available_for_swap
      if can_swap_to_others? and params[:swap_to_id].present?
        person = Roster::Person.find params[:swap_to_id]
      else
        person = current_user
      end
      new_record = resource.swap_to person
      if new_record.save
        Scheduler::SwapMailer.swap_confirmed(resource, new_record).deliver
        Scheduler::NotificationSetting.admins_to_notify_swap(resource, to_mail).each do |recipient|
          Scheduler::SwapMailer.swap_confirmed(resource, new_record, recipient).deliver
        end
        redirect_to new_record, action: :swap
        return
      else
        #pp new_record.errors
        #resource.errors = new_record.errors # get it to show errors
      end


    elsif params[:cancel_swap]
      resource.available_for_swap = false
      resource.save
    end
    show!
  end


  def current_user
    super || api_user
  end

  private

  helper_method :can_swap_to_others?, :collection_by_date
  def can_swap_to_others?
    true
  end

  def collection_by_date
    @_by_date ||= collection.reduce({}) do |hash, ass|
      fmt = "#{ass.date}-#{ass.shift.shift_group.period}"
      hash[fmt] = ass;
      hash
    end.values
  end

  def require_valid_user!
    unless current_user
      super
    end
  end


  def api_user
    if token = params[:api_token] and @person_id=Scheduler::NotificationSetting.where(calendar_api_token: token).first.try(:person)
      @api_user ||= Roster::Person.find(@person_id)
    end
  end
 
  #def collection
  #  authorize! :read, Scheduler::ShiftAssignment
#
  #  return @_collection if @_collection
#
  #  coll = super.includes(:person => [:counties, :positions])
  #  if params[:person_id]
  #    coll = coll.where(person_id: params[:person_id])
  #  else
  #    coll = coll.where(person_id: current_user).where('date >= ?', Date.yesterday)
  #  end
  #  @_collection = coll.order('date asc')
  #end

  def collection
    apply_scopes(super).order(:date).uniq
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    [params.require(:shift_assignment).permit(:person_id, :shift_id, :date)]
  end
end
