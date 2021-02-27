class Scheduler::PeopleController < Scheduler::BaseController
  inherit_resources
  include Paginatable
  respond_to :html, :csv
  respond_to :js, only: :index

  defaults resource_class: Roster::Person

  load_and_authorize_resource class: Roster::Person

  has_scope :name_contains
  has_scope :name_gteq
  has_scope :in_shift_territory, as: :shift_territory, default: Proc.new {|controller| controller.current_user.primary_shift_territory_id}

  # , default: Proc.new {|controller| controller.current_region.positions.where(name: ['DAT Team Lead', 'DAT Technician', 'DAT Trainee', 'DAT Dispatcher']).map(&:id)}
  has_scope :with_shift, type: :array, default: [] do |controller, scope, val|
    scope.where(Scheduler::ShiftAssignment.joins(:shift).where("person_id = roster_people.id").where(scheduler_shifts: {id: val}).exists)
  end
  has_scope :date_after, :allow_blank => true, :default => FiscalYear.current.start_date.to_s do |controller, scope, val|
    if not controller.params[:date_before].blank?
      scope.where(Scheduler::ShiftAssignment.where("person_id = roster_people.id").where('date > ?', val).where('date < ?', controller.params[:date_before]).exists)
    elsif not val.blank?
      scope.where(Scheduler::ShiftAssignment.where("person_id = roster_people.id").where('date > ?', val).exists)
    else
      scope.where(Scheduler::ShiftAssignment.where("person_id = roster_people.id").exists)
    end
  end
  has_scope :date_before do |controller, scope, val|
    # This is a hack, I guess, but I don't know how to do it otherwise
    # If there date_after is present, we have to let that scope handle everything
    if not controller.params[:date_after].blank?
      scope
    elsif not controller.params[:date_before].blank?
      scope.where(Scheduler::ShiftAssignment.where("person_id = roster_people.id").where('date < ?', val).exists)
    else
      scope
    end
  end

  def collection
    @collection ||= apply_scopes(super).preload(:shift_territory_memberships, :shift_territories, :positions)
  end

  helper_method :prev_shift
  def prev_shift person
    person.shift_assignments.where("date < ?", Date.current).maximum('date')
  end

  helper_method :num_shifts
  def num_shifts person
    assignments = person.shift_assignments
    if params[:with_shift]
      assignments = assignments.joins(:shift).where(scheduler_shifts: {id: params[:with_shift]})
    end
    if params[:date_after].nil?
      assignments = assignments.where("date > ?", FiscalYear.current.start_date.to_s)
    elsif not params[:date_after].blank?
      assignments = assignments.where("date > ?", params[:date_after])
    end
    if not params[:date_before].blank?
      assignments = assignments.where("date < ?", params[:date_before])
    end
    assignments.count
  end

  helper_method :shifts_assigned
  def shifts_assigned person
    assignments = person.shift_assignments
    if params[:with_shift]
      assignments = assignments.joins(:shift).where(scheduler_shifts: {id: params[:with_shift]})
    end
    assignments.map{|a| a.shift}.uniq
  end

  helper_method :next_shift
  def next_shift person
    person.shift_assignments.where("date >= ?", Date.current).minimum('date')
  end

  def default_search_params
    {date_gteq: FiscalYear.current.start_date}
    t
  end

  helper_method :date_ranges
  def date_ranges
    [ ["Now", -2],
      ["1 Week", 7],
      ["2 Weeks", 14],
      ["1 Month", 30],
      ["2 Months", 60],
      ["3 Months", 90],
      ["6 Months", 180]
    ]
  end

  def original_url
    request.original_url
  end
  helper_method :original_url

  helper_method :available_shifts
  def available_shifts
    Scheduler::Shift.for_region(current_region).active_on_day(Date.today).order(:name)
  end

end