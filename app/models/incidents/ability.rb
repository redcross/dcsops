class Incidents::Ability
  include CanCan::Ability
  include ::NewRelic::Agent::MethodTracer

  attr_reader :person

  def initialize(person)
    @person = person
    @region_scope = [@person.region_id] + Roster::Region.with_incidents_delegate_region_value(@person.region_id).pluck(:id)
    is_admin = person.has_capability 'incidents_admin'
    region_admin = person.has_capability 'region_admin'

    scopes
    personal
    
    dispatch_console        if is_admin or person.has_capability 'dispatch_console'
    create_incident         if             person.has_capability 'create_incident'
    submit_incident_report  if is_admin or person.has_capability 'submit_incident_report'
    cas_admin               if is_admin or person.has_capability 'cas_admin'
    incident_details        if is_admin or person.has_capability 'incident_details'
    cas_details             if is_admin or person.has_capability 'cas_details'
    see_responses           if is_admin or person.has_capability 'see_responses'
    approve_iir             if is_admin or person.has_capability 'approve_iir'
    incidents_admin(region_admin) if is_admin

    read_only if ENV['READ_ONLY']
    
  end

  add_method_tracer :initialize

  def scopes
    # This controls what regions this person can access in the URL
    can :read, Incidents::Scope#, region_id: person.region_id

    can :read, Roster::Region, id: @region_scope
  end

  def personal
    # for now, anyone can do the weekly subscription
    can :manage, Incidents::ReportSubscription, person_id: person.id, report_type: 'report'
    can :index, Partners::Partner, region_id: person.region_id

    can :read, Incidents::Incident
    can :read_details, Incidents::Incident
  end

  def cas_details
    can :read_case_details, Incidents::Incident
    can :read, Incidents::CasIncident, {region_id: person.region_id}
    can :narrative, Incidents::CasCase, {cas_incident: {region_id: person.region_id}}
  end

  def cas_admin
    can [:link_cas], Incidents::Incident
    can [:read, :promote, :link, :ignore], Incidents::CasIncident
    can [:manage], Incidents::CasCase
  end

  def create_incident
    can :create, Incidents::Incident, region_id: @region_scope
    can :reopen, Incidents::Incident
  end

  def submit_incident_report
    can [:needs_report, :mark_invalid, :close, :update], Incidents::Incident
    can :create, Incidents::DatIncident
    can :manage, Incidents::EventLog
    can :manage, Incidents::Attachment, {incident: {status: 'open'}}
    today = person.region.time_zone.today
    can :update, Incidents::DatIncident, {incident: {date: ((today-5)..(today+1))}}
    can :update, Incidents::DatIncident, {incident: {status: 'open'}}
    can :manage, Incidents::ResponderAssignment, {incident: {status: 'open'}} if person.region.incidents_enable_dispatch_console
    can :manage, Incidents::Case, {incident: {status: 'open'}} if person.region.incidents_collect_case_details
    can [:create, :recipients], Incidents::Notifications::Message
    can [:create, :read, :acknowledge], Incidents::ResponderMessage
    can [:create], Incidents::ResponderRecruitment
    can [:create, :read, :update], Incidents::InitialIncidentReport
  end

  def incidents_admin(region_admin)
    can :manage, Incidents::DatIncident, incident: {region_id: @region_scope}
    can :manage, Incidents::Incident, region_id: @region_scope
    if not region_admin
      cannot :close_without_completing, Incidents::Incident, region_id: @region_scope
    end
    can :manage, Incidents::InitialIncidentReport, incident: {region_id: @region_scope}
  end

  def incident_details
    can [:read_dat_details, :index], Incidents::Incident
  end

  def see_responses
    can :show, :responders
  end

  def dispatch_console
    scopes = person.scope_for_capability('dispatch_console').map(&:to_i)
    can :dispatch_console, Incidents::Scope, {id: scopes}


    dispatch_regions = Incidents::Scope.where(id: scopes).includes(:regions).flat_map{|s| s.all_regions}.map(&:id)
    can [:create, :show], Incidents::CallLog, {region_id: dispatch_regions + [nil]}
    can [:create, :index, :show, :complete, :next_contact], Incidents::Incident, {region_id: dispatch_regions}
  end

  def approve_iir
    can :manage, Incidents::InitialIncidentReport, incident: {region_id: @region_scope}
  end

  def read_only
    cannot [:mark_invalid, :reopen, :close, :update, :create, :destroy], :all
  end

  #def can? *args
  #  val = super
  #  pp 'can?', args, val
  #  val
  #end

end
