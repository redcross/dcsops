class Scheduler::PeopleController < Scheduler::BaseController
  inherit_resources

  defaults resource_class: Roster::Person

  load_and_authorize_resource class: Roster::Person

  has_scope :search_name
  has_scope :in_county, as: :county, default: Proc.new {|controller| controller.current_user.counties.first.id}
  #has_scope :in_county, as: :county do |controller, scope, val|
  #  positions = Scheduler::Shift.where(county_id: val).map{|sh| sh.positions}.flatten
  #  scope.in_county(val)
  #end
  has_scope :with_position, type: :array
  has_scope :last_shift do |controller, scope, val|
    scope.where(Scheduler::ShiftAssignment.where{(person_id == roster_people.id) & (date > (Date.current-val.to_i))}.exists.not)
  end

  def collection
    apply_scopes(super).uniq
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

end