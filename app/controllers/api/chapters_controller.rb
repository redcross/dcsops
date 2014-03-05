class Api::ChaptersController < Api::BaseController
  inherit_resources
  defaults resource_class: Roster::Chapter
  respond_to :json
  actions :index, :show
  load_and_authorize_resource class: resource_class
end