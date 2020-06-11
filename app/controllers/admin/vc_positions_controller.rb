class Admin::VcPositionsController < ApplicationController
  inherit_resources
  belongs_to :region, parent_class: Roster::Region, finder: :find_by_url_slug!
  defaults resource_class: Roster::VcImportData, singleton: true
  load_and_authorize_resource class: Roster::VcImportData
  actions :show

  def show
    unless params[:regex].present?
      render status: :bad_request, json: {error: "No filter regex specified"}
      return
    end

    resource = parent.vc_import_data
    results = resource.positions_matching params[:regex]

    render json: results
  end

  def current_ability
    AdminAbility.new(logged_in_user)
  end
end