class Scheduler::ShiftReportController < Scheduler::BaseController
  inherit_resources
  include Paginatable
  respond_to :html, :csv
  respond_to :js, only: :index

  defaults resource_class: Scheduler::ShiftAssignment

  load_and_authorize_resource class: Scheduler::ShiftAssignment

  has_scope :name_contains do |controller, scope, val|
    scope.joins(:person).merge(Roster::Person.name_contains(val))
  end
  has_scope :with_shift, type: :array do |controller, scope, val|
    scope.joins(:shift).where(scheduler_shifts: { id: val })
  end
  has_scope :date_after, :default => Date.today.to_s do |controller, scope, val|
    scope.where('date >= ?', val)
  end
  has_scope :date_before, :default => Date.today.to_s do |controller, scope, val|
    scope.where('date <= ?', val)
  end

  def collection
    @collection ||=
      apply_scopes(super).
      for_region(current_region).
      joins(:shift_time, :person).
      preload(:shift, :shift_time, :person).
      order(date: :desc).
      order('scheduler_shift_times.start_offset desc').
      order('roster_people.last_name ASC').
      order('roster_people.first_name asc')
  end

  helper_method :available_shifts
  def available_shifts
    Scheduler::Shift.for_region(current_region).active_on_day(Date.today).order(:name)
  end

  def original_url
    request.original_url
  end
  helper_method :original_url
end