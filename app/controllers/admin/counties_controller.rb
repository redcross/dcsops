class Admin::CountiesController < GridController
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!
  defaults resource_class: Roster::County
  load_and_authorize_resource class: Roster::County

  column :name
  column :abbrev
  column :vc_regex_raw

  def build_resource_params
    [params.fetch(:roster_county, {}).permit(:name, :vc_regex_raw, :abbrev)]
  end

  def current_ability
    AdminAbility.new(logged_in_user)
  end
end