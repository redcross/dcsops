class Scheduler::Ability
  include CanCan::Ability
  include ::NewRelic::Agent::MethodTracer

  attr_reader :person

  def initialize(person)
    @person = person

    personal

    shift_territory_ids = person.scope_for_capability('shift_territory_roster')
    shift_territory_roster(shift_territory_ids) if shift_territory_ids.present?

    admin_shift_territory_ids = person.scope_for_capability('shift_territory_scheduler')
    if person.has_capability 'region_scheduler'
        admin_shift_territory_ids.concat person.region.shift_territory_ids
    end
    admin_shift_territory_ids.uniq!
    scheduler admin_shift_territory_ids if admin_shift_territory_ids.present?

    region_dat_admin person.region_id if person.has_capability 'region_dat_admin'

    dat_admin_shift_territories = person.scope_for_capability('shift_territory_dat_admin')
    shift_territory_dat_admin dat_admin_shift_territories if dat_admin_shift_territories.present? # is dat shift_territory admin

    download if person.has_capability 'region_admin' or person.has_capability 'download'

    read_only if ENV['READ_ONLY']
  end

  add_method_tracer :initialize

  def personal
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], {id: person.id}
    can [:read, :destroy, :create, :swap, :update], Scheduler::ShiftAssignment, person: {id: person.id}
    can :manage, Scheduler::ShiftSwap, assignment: {person: {region_id: person.region_id}}
    can :read, :on_call unless person.region.scheduler_restrict_on_call_contacts
  end

  def scheduler ids
    can :read, Roster::Person, shift_territory_memberships: {shift_territory_id: ids}
    can :manage, Scheduler::ShiftAssignment, {person: {shift_territory_memberships: {shift_territory_id: ids}}}
  end

  def shift_territory_roster ids
    can :index, [Scheduler::FlexSchedule], {person: {shift_territory_memberships: {shift_territory_id: ids}}}
    can :index, Roster::Person, {shift_territory_memberships: {shift_territory_id: ids}}
  end

  def region_dat_admin id
    can :read, Roster::Person, region_id: id
    can :manage, Scheduler::ShiftAssignment, {person: {region_id: id}}
    can :manage, Scheduler::DispatchConfig, id: id
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], person: {region_id: id}
    can [:read, :update, :update_shifts], Scheduler::Shift, shift_territory: {region_id: id}

    can :receive_admin_notifications, Scheduler::NotificationSetting, id: person.id
    can :read, :on_call
  end

  def shift_territory_dat_admin ids
    can :read, Roster::Person, shift_territory_memberships: {shift_territory_id: ids}
    can :manage, Scheduler::ShiftAssignment, {person: {shift_territory_memberships: {shift_territory_id: ids}}}
    can :manage, Scheduler::DispatchConfig, id: ids
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], person: {shift_territory_memberships: {shift_territory_id: ids}}
    can [:read, :update, :update_shifts], Scheduler::Shift, shift_territory_id: ids

    can :receive_admin_notifications, Scheduler::NotificationSetting, id: person.id
    can :read, :on_call
  end

  def read_only
    cannot [:update, :create, :destroy], :all
  end

  def download
    can :download, Scheduler::Shift
    can :download, Roster::Person
  end
end
