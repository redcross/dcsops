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
        scope.where{person_id == my{controller.params[:person_id]}}
      else
        scope.where{person_id == my{controller.current_user.id}}
      end
    when 'all'
      controller.authorize! :read_all_shifts, Scheduler::ShiftAssignment
      county_ids = controller.current_user.county_ids
      county_ids.present? ? scope.for_counties(county_ids) : scope
    end
  end

  has_scope :time_period, default: 'future', only: [:index] do |controller, scope, arg|
    case arg
    when 'future'
      scope.normalized_date_on_or_after(controller.current_chapter.time_zone.today)
    else
      scope
    end
  end

  has_scope :for_county do |controller, scope, arg|
    scope.for_counties(Array(arg))
  end

  def current_user
    super || api_user
  end

  private

  helper_method :collection_by_date
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
    return @api_user if @api_user
    if token = params[:api_token]
      @setting = Scheduler::NotificationSetting.where(calendar_api_token: token).first
      @api_user = @setting.try(:person)
    end
  end

  def collection
    @shift_assignments ||= apply_scopes(super).order(:date).joins{person.outer}
                  .where{(person.chapter_id == my{current_chapter}) & (date <= my{current_chapter.time_zone.today + 30})}
                  .includes{[person, shift_group.chapter, shift.county, person.counties, person.chapter]}.uniq
  end

  helper_method :grouped_collection
  # For each date/shift group, return only the "most important" (ranked by ordinal) shift.  This is
  # only useful when querying all, as we'll get multiple assignments per shift and should only have
  # one event on the calendar.  The associated shifts query will get all the rest [again... should look into that].
  def grouped_collection
    @grouped_collection ||= collection.sort_by{|s| s.shift.ordinal}.uniq{|s| [s.date, s.shift_group_id, s.shift.county_id]}
  end

  # This builds a query with pairs of shift group/date
  def other_shifts
    return @other_shifts if @other_shifts

    groups = collection.map{|ass| {start_date: ass.date, id: ass.shift_group_id} }.uniq
    @other_shifts = Scheduler::ShiftAssignment.for_active_groups_raw(groups).includes{[person, shift.county]}.includes_person_carriers.group_by{|s| [s.date, s.shift_id, s.shift_group_id]}
  end

  def assignments_for(shift, item)
    other_shifts[[item.date, shift.id, item.shift_group_id]]
  end

  helper_method :associated_shifts
  def associated_shifts(item)
    @shifts_by_shift_group ||= begin
      groups = collection.map{|s| s.shift_group}.uniq
      shifts = Scheduler::Shift.for_groups(groups).order{ordinal}.active_on_day(item.date).includes{shift_groups}
      shifts.reduce(NestedHash.hash_array) { |arr, shift| shift.shift_group_ids.each { |gid| arr[gid] << shift }; arr }
    end

    @shifts_by_shift_group[item.shift_group_id].select{|s| s.county_id == item.shift.county_id}.map{|s| [s, assignments_for(s, item)]}
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    [params.require(:shift_assignment).permit(:person_id, :shift_id, :shift_group_id, :date)]
  end
end
