class Scheduler::ShiftsController < Scheduler::BaseController
  inherit_resources
  respond_to :html, :json
  load_and_authorize_resource

  actions :index

  def update_shifts
    params[:shifts].each do |shift_id, data|
      s = Scheduler::Shift.find shift_id
      authorize! :update, s
      s.update_attributes shift_params(ActionController::Parameters.new(data))
    end

    #params[:county_shifts].each do |county_id, data|
    #  data[:signups_frozen_before] = nil unless data[:signups_frozen_before].present?
    #  data[:signups_available_before] = nil unless data[:signups_available_before].present?
    #  data[:max_advance_signup] = nil unless data[:max_advance_signup].present?
#
    #  s = Scheduler::Shift.where(county_id: county_id)
    #  s.each{|shift| authorize! :update, shift}
    #  s.update_all shift_params(ActionController::Parameters.new(data))
    #end

    render action: :index
  end

  private

  helper_method :by_county_group_shift, :dates_for_count
  def counties
    current_user.counties
  end

  def by_county_group_shift
    return @tree if @tree
    @tree = collection.sort_by{|sh| sh.ordinal || Float::INFINITY}.group_by(&:county)
  end

  def collection
    @collection ||= super.includes{[county, shift_times]}
  end

  def dates_for_count
    [Date.current.at_beginning_of_month, Date.current.at_beginning_of_month.next_month]
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params()
      [params.require(:scheduler_shift).permit(:name, :abbrev, :shift_time_id, :max_signups, :county_id, :ordinal)]
    end

    def shift_params(hash=params)
      hash.permit(:signups_frozen_before, :signups_available_before, :max_advance_signup)
    end
end
