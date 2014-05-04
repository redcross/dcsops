class Partners::PartnersController < Partners::BaseController
  respond_to :html, :json
  inherit_resources
  load_and_authorize_resource
  include Searchable
end