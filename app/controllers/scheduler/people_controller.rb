class Scheduler::PeopleController < Scheduler::BaseController
  inherit_resources
  include Paginatable
  respond_to :html
  respond_to :js, only: :index

  defaults resource_class: Roster::Person

  load_and_authorize_resource class: Roster::Person

  has_scope :name_contains
  has_scope :in_shift_territory, as: :shift_territory, default: Proc.new {|controller| controller.current_user.primary_shift_territory_id}
  #has_scope :in_shift_territory, as: :shift_territory do |controller, scope, val|
  #  positions = Scheduler::Shift.where(shift_territory_id: val).map{|sh| sh.positions}.flatten
  #  scope.in_shift_territory(val)
  #end

  # , default: Proc.new {|controller| controller.current_region.positions.where(name: ['DAT Team Lead', 'DAT Technician', 'DAT Trainee', 'DAT Dispatcher']).map(&:id)}
  has_scope :with_position, type: :array, default: []
  has_scope :last_shift do |controller, scope, val|
    scope.where(Scheduler::ShiftAssignment.where(person_id: roster_people.id.where('date > ?', Date.current-val.to_i).exists.not)
  end

  def collection
    @collection ||= apply_scopes(super).preload(:shift_territory_memberships, :shift_territories, :positions).uniq
  end

  helper_method :prev_shift
  def prev_shift person
    person.shift_assignments.where("date < ?", Date.current).maximum('date')
  end

  helper_method :num_shifts
  def num_shifts person
    person.shift_assignments.where("date < ?", Date.current).count
  end

  helper_method :next_shift
  def next_shift person
    person.shift_assignments.where("date >= ?", Date.current).minimum('date')
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

end