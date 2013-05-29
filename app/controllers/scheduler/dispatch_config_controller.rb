class Scheduler::DispatchConfigController < Scheduler::BaseController
  inherit_resources
  load_and_authorize_resource
  respond_to :html, :json

  private
  def collection
    super.includes(:county).where(roster_counties: {chapter_id: current_user.chapter_id}).accessible_by(current_ability)
  end

  def resource
    Scheduler::DispatchConfig.for_county Roster::County.find(params[:id])
  end

  helper_method :all_people
  def all_people
    Roster::Person.by_name.where(chapter: current_user.chapter)
  end

  def resource_params
    [params.require(:scheduler_dispatch_config).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id)]
  end
end