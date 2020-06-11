class Incidents::EditPanelController < Incidents::BaseController

  inherit_resources
  load_and_authorize_resource :region
  load_and_authorize_resource
  def self.belongs_to_incident
    belongs_to :region, finder: :find_by_url_slug!, parent_class: Roster::Region
    belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident
    actions :all, except: [:index, :show]
  end

  respond_to :html, :js

  layout ->controller{ controller.request.xhr? ? false : nil }
  responders EditablePanelResponder

  class_attribute :panel_name

  expose(:panel_name) { Array(self.class.panel_name) }

  before_action :check_incident_open

  def update
    action = params[:action] == 'create' ? :create! : :update!
    self.send(action) { after_create_url }
  end
  alias_method :create, :update

  helper_method :form_url
  def form_url
    url_for({action: resource.persisted? ? :update : :create})
  end

  protected

  def after_create_url
    if parent? 
      parent_path({anchor: "inc-"+Array(self.class.panel_name).first})
    else
      url_for(action: :index)
    end
  end

  def check_incident_open
    unless @incident.nil? || parent.status == 'open'
      flash[:error] = "The incident is not open for editing."
      redirect_to parent_path
    end
  end
end
