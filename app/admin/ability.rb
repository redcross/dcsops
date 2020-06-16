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
      can :read, [Roster::Person, Roster::ShiftTerritory, Roster::Position], region_id: region
      can :impersonate, Roster::Person, region_id: region
      can :manage, Logistics::Vehicle, region_id: region
      can :manage, HomepageLink, region_id: region
      can :new, Incidents::ReportSubscription
      can :manage, Incidents::ReportSubscription, person: {region_id: region}
      can [:test_report, :send_report, :new], Incidents::ReportSubscription

      can :manage, Incidents::Notifications::Event, region_id: region
      can :manage, Incidents::Notifications::Role, region_id: region

      can [:read, :update], Scheduler::DispatchConfig, region_id: region
      can :read, Incidents::DispatchLog, region_id: region

      can :manage, Incidents::ResponseTerritory, region_id: region

      can :manage, RegionAdminProxy do |region|
        region.region_id.nil? || region.region_id == region
      end
    end
  end

end