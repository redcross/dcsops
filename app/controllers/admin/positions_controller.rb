class Admin::PositionsController < GridController
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!
  defaults resource_class: Roster::Position
  load_and_authorize_resource class: Roster::Position

  column :name
  column :abbrev
  column :vc_regex_raw
  column :hidden

  def build_resource_params
    [params.fetch(:roster_position, {}).permit(:name, :vc_regex_raw, :hidden, :abbrev)]
  end

  def current_ability
    AdminAbility.new(logged_in_user)
  end
end