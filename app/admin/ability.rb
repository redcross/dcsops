class AdminAbility
  include CanCan::Ability

  def initialize(person)

    is_config = person.roles.any?{|r| r.grant_name == 'chapter_config' }

    if is_config # is site manager
      can [:read, :update], Roster::Chapter, id: person.chapter_id
      can :manage, Roster::County
      can :manage, Roster::Position
      can :manage, Roster::CellCarrier
      can :manage, Roster::Person
      can :manage, Roster::Role

      can :manage, Scheduler::DispatchConfig
      can :manage, Scheduler::Shift
      can :manage, Scheduler::ShiftGroup
    end

  end

end