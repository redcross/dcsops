class AdminAbility
  include CanCan::Ability

  def initialize(person)

    is_config = person.has_role 'chapter_config'

    if is_config and false# is site manager
      can [:read, :update], Roster::Chapter
      can :manage, Roster::County
      can :manage, Roster::Position
      can :manage, Roster::CellCarrier
      can :manage, Roster::Person
      can :manage, Roster::Role

      can :manage, Scheduler::DispatchConfig
      can :manage, Scheduler::Shift
      can :manage, Scheduler::ShiftGroup

      can :manage, Incidents::NotificationSubscription
      can :manage, Incidents::PriceListItem

      can :manage, Logistics::Vehicle

      can :manage, ImportLog
      can :manage, MOTD

      can :manage, Partners::Partner

      can :manage, ApiClient
      can :manage, NamedQuery
      can :manage, DataFilter
      can :manage, HomepageLink
    end

    is_admin = person.has_role 'chapter_admin'
    if is_admin or true
      chapter = person.chapter_id
      can :read, [Roster::Person, Roster::County, Roster::Position], chapter_id: chapter
      can :impersonate, Roster::Person, chapter_id: chapter
      can :manage, Logistics::Vehicle, chapter_id: chapter
      can :manage, Incidents::NotificationSubscription, person: {chapter_id: chapter}
    end
  end

end