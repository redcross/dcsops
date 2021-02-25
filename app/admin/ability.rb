class AdminAbility
  include CanCan::Ability

  class RegionAdminProxy
    attr_accessor :region_id
    def initialize(region)
      @region_id = region.id if !region.kind_of? Class
    end
  end

  def initialize(person)

    is_config = person.has_capability 'region_config'

    if is_config # is site manager
      can [:read, :update], Roster::Region
      can :manage, Roster::ShiftTerritory
      can :manage, Roster::Position
      can :manage, Roster::CellCarrier
      can :manage, Roster::Person
      can :manage, Roster::Capability
      can :manage, Roster::VcPosition

      can :manage, Scheduler::DispatchConfig
      can :manage, Scheduler::Shift
      can :manage, Scheduler::ShiftTime
      can :manage, Scheduler::ShiftCategory

      can :manage, Incidents::ReportSubscription
      can :manage, Incidents::PriceListItem
      can :manage, Incidents::CallLog

      can :manage, Logistics::Vehicle


      can :manage, Core::JobLog
      can :manage, MOTD

      can :manage, Partners::Partner

      can :manage, NamedQuery
      can :manage, DataFilter
      can :manage, HomepageLink
      can :manage, Lookup
      can :manage, Delayed::Job

      can :manage, :all
    end

    is_admin = person.has_capability 'region_admin'
    if is_admin
      region = person.region_id
      can :manage, [Roster::Person, Roster::ShiftTerritory, Roster::Position, Scheduler::ShiftCategory, Scheduler::ShiftTime], region_id: region
      can :impersonate, Roster::Person, region_id: region
      can :manage, Partners::Partner, region_id: region
      can :manage, Logistics::Vehicle, region_id: region
      can :manage, Roster::VcPosition, region_id: region
      can :manage, HomepageLink, region_id: region
      can :manage, MOTD, region_id: region

      can :read, Incidents::Notifications::Event, region_id: region
      can :manage, Incidents::Notifications::Role, region_id: region

      can [:read, :update], Scheduler::DispatchConfig, region_id: region
      can :manage, Scheduler::Shift, shift_territory: Roster::ShiftTerritory.where(region_id: region).all + [nil]
    end
  end

end