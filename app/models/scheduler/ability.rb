class Scheduler::Ability
  include CanCan::Ability

  def initialize(person)

    county_ids = person.county_ids

    #can :read, Roster::Person, id: person.id
    #can :read, Scheduler::ShiftAssignment, shift: {county_id: county_ids}
    can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], {id: person.id}
    can [:read, :destroy, :create, :swap], Scheduler::ShiftAssignment, person: {id: person.id}
    can :swap, Scheduler::ShiftAssignment, {available_for_swap: true}

    county_ids = person.scope_for_role('county_roster')
    if county_ids.present?
        can :index, [Scheduler::FlexSchedule], {person: {county_memberships: {county_id: county_ids}}}
        can :index, Roster::Person, {county_memberships: {county_id: county_ids}}
    end

    admin_county_ids = person.scope_for_role('county_scheduler')
    if person.has_role 'chapter_scheduler'
        admin_county_ids = admin_county_ids + person.chapter.county_ids
    end
    admin_county_ids.uniq!
    if admin_county_ids.present?
        can :read, Roster::Person, county_memberships: {county_id: admin_county_ids}
        can :manage, Scheduler::ShiftAssignment, {person: {county_memberships: {county_id: admin_county_ids}}}
    end

    admin_county_ids = person.scope_for_role('county_dat_admin')
    if person.has_role 'chapter_dat_admin'
        admin_county_ids = admin_county_ids + person.chapter.county_ids
    end
    admin_county_ids = admin_county_ids.uniq

    if true and admin_county_ids.present? # is dat county admin
        can :read, Roster::Person, county_memberships: {county_id: admin_county_ids}
        can :manage, Scheduler::ShiftAssignment, {person: {county_memberships: {county_id: admin_county_ids}}}
        can :manage, Scheduler::DispatchConfig, id: admin_county_ids
        can [:read, :update], [Scheduler::NotificationSetting, Scheduler::FlexSchedule], person: {county_memberships: {county_id: admin_county_ids}}
        can [:read, :update, :update_shifts], Scheduler::Shift, county_id: admin_county_ids

        can :receive_admin_notifications, Scheduler::NotificationSetting, id: person.id
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
