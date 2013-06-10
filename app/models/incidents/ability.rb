class Incidents::Ability
  include CanCan::Ability

  def initialize(person)
    return unless %w(Laxson Hersher Hancock Terrell).include? person.last_name

    can :read, :incidents
    can [:read, :needs_report], Incidents::Incident

    can :read_details, Incidents::Incident
    can :read_case_details, Incidents::Incident
    can :read_dat_details, Incidents::Incident

    can [:create, :update], Incidents::DatIncident

    # Admin Privs
    can [:read, :promote, :link_cas], Incidents::CasIncident
  end
end
