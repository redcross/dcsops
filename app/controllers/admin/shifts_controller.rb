class Admin::ShiftsController < GridController
  belongs_to :region, parent_class: Roster::Region, finder: :find_by_url_slug!
  defaults resource_class: Scheduler::Shift
  load_and_authorize_resource class: Scheduler::Shift

  column :name
  column :abbrev, input_html: {style: "width: 60px"}
  column :shift_territory, collection: ->{region.shift_territories}, member_label: :name
  column :ordinal, input_html: {style: "width: 50px"}
  column :max_signups, input_html: {style: "width: 50px"}
  column :min_desired_signups, input_html: {style: "width: 50px"}
  column :ignore_shift_territory, as: :boolean
  column :exclusive, label: ''
  #column :positions, as: :check_boxes, collection: ->{region.positions}
  column :shift_times, as: :check_boxes, collection: ->{shift_times}, member_label: :name, input_html: {class: ""}
  column :shift_category, collection: ->{shift_categories}, member_label: :name

  def build_resource_params
    [params.fetch(:scheduler_shift, {}).permit(:name, :abbrev, :shift_territory_id, :ordinal, :max_signups, :min_desired_signups, :ignore_shift_territory, :exclusive, :shift_category_id, :position_ids => [], shift_time_ids: [])]
  end

  def current_ability
    AdminAbility.new(logged_in_user)
  end

  def end_of_association_chain
    Scheduler::Shift.for_region(parent).order([:ordinal]).includes{[shift_times, shift_territory, positions, shift_category]}
  end

  def resource
    @shift ||= end_of_association_chain.find_by!(id: params[:id])
  end

  def collection
    @_coll ||= super.order(:shift_territory_id, :ordinal)
  end

  def region
    parent
  end
  helper_method :region

  def shift_times
    @groups ||= Scheduler::ShiftTime.for_region(region)
  end
  def shift_categories
    @categories ||= Scheduler::ShiftCategory.for_region(region)
  end
  helper_method :shift_times, :shift_categories
end
