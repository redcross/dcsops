class Incidents::IncidentsController < Incidents::BaseController
  inherit_resources
  defaults finder: :find_by_incident_number!
  load_and_authorize_resource except: [:link_cas, :needs_report]

  custom_actions collection: [:needs_report, :link_cas, :tracker]

  has_scope :in_county, as: :county_id_eq

  def create
    create! { new_incidents_incident_dat_path(resource) }
  end

  def link_cas
    authorize! :read, Incidents::CasIncident
    if request.post? and params[:cas_id] and params[:incident_id]
      cas = Incidents::CasIncident.find params[:cas_id]
      incident = Incidents::Incident.find params[:incident_id]

      authorize! :link, cas

      incident.link_to_cas_incident(cas)
    elsif request.post? and params[:cas_id] and params[:commit] == 'Promote to Incident'
      cas = Incidents::CasIncident.find params[:cas_id]

      authorize! :promote, cas
      cas.create_incident_from_cas!
    end
  end

  private

    helper_method :cas_incidents_to_link, :incidents_for_cas
    def cas_incidents_to_link
      @_cas ||= Incidents::CasIncident.where{incident_id == nil}.order{incident_date.desc}
    end

    def county_names
      @_names ||= current_user.chapter.counties.map(&:name)
    end

    def incidents_for_cas(cas)
      scope = Incidents::Incident.joins{cas_incident.outer}.where{(cas_incident.id == nil) & date.in((cas.incident_date.last_week)..(cas.incident_date.next_week))}
      if county_names.include? cas.county_name
        scope = scope.joins{county}.where{county.name == cas.county_name}
      end
      scope
    end

    helper_method :needs_report_collection
    def needs_report_collection
      @_report_collection ||= end_of_association_chain.joins{dat_incident.outer}.where{(dat_incident.id == nil) & ((ignore_incident_report != true) | (ignore_incident_report == nil))}
    end

    helper_method :tracker_collection
    def tracker_collection
      @_tracker_collection ||= apply_scopes(end_of_association_chain).joins{cas_incident.cases.outer}.where{((cas_incident.cases_open > 0) | (cas_incident.last_date_with_open_cases >= 7.days.ago)) & (cas_incident.cases.case_last_updated > 2.months.ago)}.includes{cas_incident.cases}.uniq
          .order{date.desc}
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      keys = [:county_id, :cas_incident_number, :incident_call_type, :team_lead_id,
             :date, :city, :address, :state, :cross_street, :zip, :lat, :lng,
             :units_affected, :num_adults, :num_children, :num_families, :num_cases, 
             :incident_type, :incident_description, :narrative_brief, :narrative]

      keys << :incident_number if params[:action] == 'create'


      request.get? ? [] : [params.require(:incidents_incident).permit(*keys).merge!({chapter_id: current_user.chapter_id})]
    end
end
