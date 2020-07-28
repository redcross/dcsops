class Admin::ShiftTerritoriesController < GridController
  belongs_to :region, parent_class: Roster::Region, finder: :find_by_url_slug!
  defaults resource_class: Roster::ShiftTerritory
  load_and_authorize_resource class: Roster::ShiftTerritory

  column :name
  column :abbrev

  def build_resource_params
    [params.fetch(:roster_shift_territory, {}).permit(:name, :abbrev)]
  end

  def current_ability
    AdminAbility.new(logged_in_user)
  end
end