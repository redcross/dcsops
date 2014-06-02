class Incidents::Ability
  include CanCan::Ability

  attr_reader :person

  def initialize(person)
    @person = person
    is_admin = person.has_role 'incidents_admin'

    scopes
    personal
    
    create_incident         if             person.has_role 'create_incident'
    submit_incident_report  if is_admin or person.has_role 'submit_incident_report'
    cas_admin               if is_admin or person.has_role 'cas_admin'
    incident_details        if is_admin or person.has_role 'incident_details'
    cas_details             if is_admin or person.has_role 'cas_details'
    see_responses           if is_admin or person.has_role 'see_responses'
    incidents_admin         if is_admin

    read_only if ENV['READ_ONLY']
    
  end

  def scopes
    # This controls what chapters this person can access in the URL
    can :read, Incidents::Scope#, chapter_id: person.chapter_id

    can :read, Roster::Chapter, id: person.chapter_id
    can :read, Roster::Chapter do |chapter|
        chapter.incidents_delegate_chapter == person.chapter_id
    end
  end

  def personal
    # for now, anyone can do the weekly subscription
    can :manage, Incidents::NotificationSubscription, person_id: person.id, notification_type: 'report'
    can :index, Partners::Partner, chapter_id: person.chapter_id

    can :read, Incidents::Incident
    can :read_details, Incidents::Incident
  end

  def cas_details
    can :read_case_details, Incidents::Incident
    can :read, Incidents::CasIncident, {chapter_id: person.chapter_id}
    can :narrative, Incidents::CasCase, {cas_incident: {chapter_id: person.chapter_id}}
  end

  def cas_admin
    can [:link_cas], Incidents::Incident
    can [:read, :promote, :link, :ignore], Incidents::CasIncident
    can [:manage], Incidents::CasCase
  end

  def create_incident
    can :create, Incidents::Incident
    can :reopen, Incidents::Incident
  end

  def submit_incident_report
    can [:needs_report, :mark_invalid, :close, :update], Incidents::Incident
    can :create, Incidents::DatIncident
    can :manage, Incidents::EventLog
    can :manage, Incidents::Attachment, {incident: {status: 'open'}}
    today = person.chapter.time_zone.today
    can :update, Incidents::DatIncident, {incident: {date: ((today-5)..(today+1))}}
    can :manage, Incidents::ResponderAssignment, {incident: {status: 'open'}} if person.chapter.incidents_enable_dispatch_console
    can :manage, Incidents::Case, {incident: {status: 'open'}} if person.chapter.incidents_collect_case_details
    can [:create, :recipients], Incidents::Notifications::Message
    can [:create, :read, :acknowledge], Incidents::ResponderMessage
    can [:create], Incidents::ResponderRecruitment
    can :manage, :chat
  end

  def incidents_admin
    can :manage, Incidents::DatIncident
    can :manage, Incidents::Incident
  end

  def incident_details
    can [:read_dat_details, :index], Incidents::Incident
  end

  def see_responses
    can :show, :responders
  end

  def read_only
    cannot [:mark_invalid, :reopen, :close, :update, :create, :destroy], :all
  end

end
