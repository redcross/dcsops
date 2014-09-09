class Admin::ShiftsController < GridController
  belongs_to :chapter, parent_class: Roster::Chapter, finder: :find_by_url_slug!
  defaults resource_class: Scheduler::Shift
  load_and_authorize_resource class: Scheduler::Shift

  column :name
  column :abbrev, input_html: {style: "width: 60px"}
  column :county, collection: ->{chapter.counties}, member_label: :name
  column :ordinal, input_html: {style: "width: 50px"}
  column :max_signups, input_html: {style: "width: 50px"}
  column :min_desired_signups, input_html: {style: "width: 50px"}
  column :ignore_county, as: :boolean
  column :exclusive, label: ''
  #column :positions, as: :check_boxes, collection: ->{chapter.positions}
  column :shift_groups, as: :check_boxes, collection: ->{shift_groups}, member_label: :name, input_html: {class: ""}
  column :shift_category, collection: ->{shift_categories}, member_label: :name

  def build_resource_params
    [params.fetch(:scheduler_shift, {}).permit(:name, :abbrev, :county_id, :ordinal, :max_signups, :min_desired_signups, :ignore_county, :exclusive, :shift_category_id, :position_ids => [], shift_group_ids: [])]
  end

  def current_ability
    AdminAbility.new(logged_in_user)
  end

  def end_of_association_chain
    Scheduler::Shift.for_chapter(parent).order([:ordinal]).includes{[shift_groups, county, positions, shift_category]}
  end

  def resource
    @shift ||= end_of_association_chain.find_by!(id: params[:id])
  end

  def collection
    @_coll ||= super.order{[county_id, ordinal]}
  end

  def chapter
    parent
  end
  helper_method :chapter

  def shift_groups
    @groups ||= Scheduler::ShiftGroup.for_chapter(chapter)
  end
  def shift_categories
    @categories ||= Scheduler::ShiftCategory.for_chapter(chapter)
  end
  helper_method :shift_groups, :shift_categories
end
