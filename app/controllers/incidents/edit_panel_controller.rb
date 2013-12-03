class Incidents::EditPanelController < Incidents::BaseController

  inherit_resources
  load_and_authorize_resource
  belongs_to :incident, finder: :find_by_incident_number!, parent_class: Incidents::Incident

  actions :all, except: [:index, :show]

  respond_to :html, :js

  layout ->controller{ controller.request.xhr? ? false : nil }
  responders EditablePanelResponder

  class_attribute :panel_name

  expose(:panel_name) { self.class.panel_name }
end
