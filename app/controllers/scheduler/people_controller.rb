class Scheduler::PeopleController < Scheduler::BaseController
  inherit_resources
  include Paginatable
  respond_to :html
  respond_to :js, only: :index

  defaults resource_class: Roster::Person

  load_and_authorize_resource class: Roster::Person

  has_scope :name_contains
  has_scope :in_county, as: :county, default: Proc.new {|controller| controller.current_user.primary_county_id}
  #has_scope :in_county, as: :county do |controller, scope, val|
  #  positions = Scheduler::Shift.where(county_id: val).map{|sh| sh.positions}.flatten
  #  scope.in_county(val)
  #end

  # , default: Proc.new {|controller| controller.current_chapter.positions.where(name: ['DAT Team Lead', 'DAT Technician', 'DAT Trainee', 'DAT Dispatcher']).map(&:id)}
  has_scope :with_position, type: :array, default: []
  has_scope :last_shift do |controller, scope, val|
    scope.where(Scheduler::ShiftAssignment.where(person_id: roster_people.id.where('date > ?', Date.current-val.to_i).exists.not)
  end

  def collection
    @collection ||= apply_scopes(super).preload(:county_memberships, :counties, :positions).select(
      "roster_people.*, roster_people.last_name, roster_people.first_name, " +
      "(SELECT count(*) FROM scheduler_shift_assignments sa WHERE sa.person_id=roster_people.id AND date < '#{Date.current}') AS num_shifts, " +
      "(SELECT min(date) FROM scheduler_shift_assignments sa WHERE sa.person_id=roster_people.id AND date >= '#{Date.current}') AS next_shift," +
      "(SELECT max(date) FROM scheduler_shift_assignments sa WHERE sa.person_id=roster_people.id AND date < '#{Date.current}') AS prev_shift"
    ).uniq
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