class Incidents::Ability
  include CanCan::Ability

  def initialize(person)
    can :read, :incidents
    can [:read], Incidents::Incident
    can :read_details, Incidents::Incident

    is_admin = person.has_role 'incidents_admin'

    # for now, anyone can do the weekly subscription
    can :manage, Incidents::NotificationSubscription, person_id: person.id, notification_type: 'report'
    can :index, Partners::Partner, chapter_id: person.chapter_id

    if person.has_role 'create_incident'
        can :create, Incidents::Incident
        can :reopen, Incidents::Incident
    end

    if is_admin or person.has_role 'submit_incident_report'
        can [:needs_report, :mark_invalid, :close], Incidents::Incident
        can :create, Incidents::DatIncident
        can :manage, Incidents::EventLog, {incident: {status: 'open'}}
        can :manage, Incidents::Attachment, {incident: {status: 'open'}}
        today = person.chapter.time_zone.today
        can :update, Incidents::DatIncident, {incident: {date: ((today-5)..(today+1))}}
        can :manage, Incidents::ResponderAssignment, {incident: {status: 'open'}} if person.chapter.incidents_enable_dispatch_console
        can :manage, Incidents::Case, {incident: {status: 'open'}} if person.chapter.incidents_collect_case_details
        can [:create, :recipients], Incidents::Notifications::Message
        can [:create, :read, :acknowledge], Incidents::ResponderMessage
    end

    if is_admin or person.has_role 'cas_admin'
        can [:link_cas], Incidents::Incident
        can [:read, :promote, :link, :ignore], Incidents::CasIncident
        can [:manage], Incidents::CasCase
    end

    if is_admin or person.has_role 'incident_details'
        can [:read_dat_details, :index], Incidents::Incident
    end

    if is_admin or person.has_role 'cas_details'
        can :read_case_details, Incidents::Incident
        can :read, Incidents::CasIncident, {chapter_id: person.chapter_id}
        can :narrative, Incidents::CasCase, {cas_incident: {chapter_id: person.chapter_id}}
    end

    if is_admin or person.has_role 'see_responses'
        can :show, :responders
    end

    if is_admin
        can :manage, Incidents::DatIncident
        can :manage, Incidents::Incident
    end
    
  end
end
