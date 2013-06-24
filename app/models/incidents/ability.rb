class Incidents::Ability
  include CanCan::Ability

  def initialize(person)
    can :read, :incidents
    can [:read], Incidents::Incident
    can :read_details, Incidents::Incident

    is_admin = person.has_role 'incidents_admin'

    # for now, anyone can do the weekly subscription
    can :manage, Incidents::NotificationSubscription, person_id: person.id, notification_type: 'weekly'

    if is_admin or person.has_role 'submit_incident_report'
        can :needs_report, Incidents::Incident
        can :create, Incidents::DatIncident
        can :create, Incidents::EventLog
    end

    if is_admin or person.has_role 'cas_admin'
        can [:link_cas], Incidents::Incident
        can [:read, :promote, :link], Incidents::CasIncident
        can [:manage], Incidents::CasCase
    end

    if is_admin or person.has_role 'incident_details'
        can :read_dat_details, Incidents::Incident
    end

    if is_admin or person.has_role 'cas_details'
        can :tracker, Incidents::Incident
        can :read_case_details, Incidents::Incident
        can :narrative, Incidents::CasCase
    end

    if is_admin
        can :manage, Incidents::DatIncident
        can :manage, Incidents::Incident
    end
    
  end
end
