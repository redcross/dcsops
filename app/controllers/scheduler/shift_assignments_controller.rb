class Scheduler::ShiftAssignmentsController < Scheduler::BaseController
  inherit_resources
  authorize_resource class_name: 'Scheduler::ShiftAssignment'

  respond_to :html, :json
  respond_to :ics, only: [:index]

  has_scope :show_shifts, default: 'mine', only: [:index] do |controller, scope, arg|
    new_scope = case arg
    when 'mine'
      if controller.params[:person_id]
        controller.authorize! :read, Scheduler::ShiftAssignment.new(person_id: controller.params[:person_id])
        scope.where(person_id: controller.params[:person_id])
      else
        scope.where(person_id: controller.current_user.id)
      end
    when 'all'
      controller.authorize! :read_all_shifts, Scheduler::ShiftAssignment
      shift_territory_ids = controller.current_user.shift_territory_ids
      shift_territory_ids.present? ? scope.for_shift_territories(shift_territory_ids) : scope
    end
  end

  has_scope :time_period, default: 'future', only: [:index] do |controller, scope, arg|
    case arg
    when 'future'
      scope.normalized_date_on_or_after(controller.current_region.time_zone.today)
    else
      scope
    end
  end

  has_scope :for_shift_territory do |controller, scope, arg|
    scope.for_shift_territories(Array(arg))
  end

  def current_user
    super || api_user
  end

  private

  helper_method :collection_by_date
  def collection_by_date
    @_by_date ||= collection.reduce({}) do |hash, ass|
      fmt = "#{ass.date}-#{ass.shift.shift_time.period}"
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
    return @api_user if @api_user
    if token = params[:api_token]
      @setting = Scheduler::NotificationSetting.where(calendar_api_token: token).first
      @api_user = @setting.try(:person)
    end
  end

  def collection
    @shift_assignments ||= apply_scopes(super).order(:date).left_outer_joins(:person)
                  .where(roster_people: { region_id: current_region})
                  .where('date <= ?', current_region.time_zone.today + 30)
                  .includes(:person, shift_time: :region, shift: :shift_territory, person: [:shift_territories, :region]).uniq
  end

  helper_method :grouped_collection
  # For each date/shift time, return only the "most important" (ranked by ordinal) shift.  This is
  # only useful when querying all, as we'll get multiple assignments per shift and should only have
  # one event on the calendar.  The associated shifts query will get all the rest [again... should look into that].
  def grouped_collection
    @grouped_collection ||= collection.sort_by{|s| s.shift.ordinal}.uniq{|s| [s.date, s.shift_time_id, s.shift.shift_territory_id]}
  end

  # This builds a query with pairs of shift time/date
  def other_shifts
    return @other_shifts if @other_shifts

    groups = collection.map{|ass| {start_date: ass.date, id: ass.shift_time_id} }.uniq
    @other_shifts = Scheduler::ShiftAssignment.for_active_groups_raw(groups).includes(:person, shift: :shift_territory).includes_person_carriers.group_by{|s| [s.date, s.shift_id, s.shift_time_id]}
  end

  def assignments_for(shift, item)
    other_shifts[[item.date, shift.id, item.shift_time_id]]
  end

  helper_method :associated_shifts
  def associated_shifts(item)
    @shifts_by_shift_time ||= begin
      groups = collection.map{|s| s.shift_time}.uniq
      shifts = Scheduler::Shift.for_groups(groups).order(:ordinal).active_on_day(item.date).includes(:shift_times)
      shifts.reduce(Core::NestedHash.hash_array) { |arr, shift| shift.shift_time_ids.each { |gid| arr[gid] << shift }; arr }
    end

    @shifts_by_shift_time[item.shift_time_id].select{|s| s.shift_territory_id == item.shift.shift_territory_id}.map{|s| [s, assignments_for(s, item)]}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    [params.require(:shift_assignment).permit(:person_id, :shift_id, :shift_time_id, :date)]
  end
end
