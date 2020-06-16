class Scheduler::FlexSchedulesController < Scheduler::BaseController
  inherit_resources
  respond_to :html, :json
  helper EditableHelper
  load_and_authorize_resource
  include Searchable

  actions :index, :show, :update

  has_scope :for_shift_territory, as: :shift_territory, default: Proc.new {|controller| controller.current_user.primary_shift_territory_id}
  has_scope :available, type: :array do |controller, scope, val|
    if val
      val.each do |period|
        # We seem to be running into the issue here:
        # https://github.com/heartcombo/has_scope/issues/84
        #
        # This caused the query to get added twice, but in a weird order that
        # was affecting how activerecord was querying postgres, putting the arguments
        # out of order, making it so the person id was being put in a boolean column.
        #
        # The issue was closed, most likely due to not being reproducible by the maintainer,
        # and instead of chasing things down today, we're going # to route around it by
        # checking if the addition to the scope we were going to do is already there.
        if not scope.where_values_hash.key?("available_#{period}") then
          scope = scope.where("available_#{period}" => true)
        end
      end
    end
    scope
  end
  has_scope :with_availability, type: :boolean, default: true

  private
    # Use callbacks to share common setup or constraints between actions.
    def resource
      @flex_schedule ||= Scheduler::FlexSchedule.where(id: params[:id]).first_or_create!
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      shifts = Scheduler::FlexSchedule.available_columns
      [params.require(:scheduler_flex_schedule).permit(*shifts)]
    end

    def collection
      @collection ||= apply_scopes(super).uniq.preload(person: [:positions, :shift_territories, :home_phone_carrier, :work_phone_carrier, :alternate_phone_carrier, :cell_phone_carrier, :sms_phone_carrier])
    end
end
