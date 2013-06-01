class Scheduler::FlexSchedulesController < Scheduler::BaseController
  inherit_resources
  respond_to :html, :json
  load_and_authorize_resource

  has_scope :for_county, as: :county, default: Proc.new {|controller| controller.current_user.primary_county_id}
  has_scope :available, type: :array do |controller, scope, val|
    if val
      val.each do |period|
        scope = scope.where("available_#{period}" => true)
      end
    end
    scope
  end
  has_scope :with_availability, type: :boolean, default: true

  private
  helper_method :days_of_week, :shift_times
    def days_of_week
      %w(sunday monday tuesday wednesday thursday friday saturday)
    end

    def shift_times
      %w(day night)
    end
    # Use callbacks to share common setup or constraints between actions.
    def resource
      Scheduler::FlexSchedule.where(id: params[:id]).first_or_create!
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      shifts = days_of_week.map{|day|
        shift_times.map{|time|"available_#{day}_#{time}".to_sym}
      }.flatten
      [params.require(:scheduler_flex_schedule).permit(*shifts)]
    end

    def collection
      apply_scopes(super).with_availability
    end
end
