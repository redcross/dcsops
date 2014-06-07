class Scheduler::Ability
  include CanCan::Ability

  attr_reader :person

  def initialize(person)
    @person = person

    personal

    county_ids = person.scope_for_role('county_roster')
    county_roster(county_ids) if county_ids.present?

    admin_county_ids = person.scope_for_role('county_scheduler')
    if person.has_role 'chapter_scheduler'
        admin_county_ids.concat person.chapter.county_ids
    end
    admin_county_ids.uniq!
    scheduler admin_county_ids if admin_county_ids.present?

    chapter_dat_admin person.chapter_id if person.has_role 'chapter_dat_admin'

    dat_admin_counties = person.scope_for_role('county_dat_admin')
    county_dat_admin dat_admin_counties if dat_admin_counties.present? # is dat county admin

    read_only if ENV['READ_ONLY']
  end

  def personal
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], {id: person.id}
    can [:read, :destroy, :create, :swap], Scheduler::ShiftAssignment, person: {id: person.id}
    can :manage, Scheduler::ShiftSwap, assignment: {person: {chapter_id: person.chapter_id}}
  end

  def scheduler ids
    can :read, Roster::Person, county_memberships: {county_id: ids}
    can :manage, Scheduler::ShiftAssignment, {person: {county_memberships: {county_id: ids}}}
  end

  def county_roster ids
    can :index, [Scheduler::FlexSchedule], {person: {county_memberships: {county_id: ids}}}
    can :index, Roster::Person, {county_memberships: {county_id: ids}}
  end

  def chapter_dat_admin id
    can :read, Roster::Person, chapter_id: id
    can :manage, Scheduler::ShiftAssignment, {person: {chapter_id: id}}
    can :manage, Scheduler::DispatchConfig, id: id
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], person: {chapter_id: id}
    can [:read, :update, :update_shifts], Scheduler::Shift, county: {chapter_id: id}

    can :receive_admin_notifications, Scheduler::NotificationSetting, id: person.id
  end

  def county_dat_admin ids
    can :read, Roster::Person, county_memberships: {county_id: ids}
    can :manage, Scheduler::ShiftAssignment, {person: {county_memberships: {county_id: ids}}}
    can :manage, Scheduler::DispatchConfig, id: ids
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], person: {county_memberships: {county_id: ids}}
    can [:read, :update, :update_shifts], Scheduler::Shift, county_id: ids

    can :receive_admin_notifications, Scheduler::NotificationSetting, id: person.id
  end

  def read_only
    cannot [:update, :create, :destroy], :all
  end
end
