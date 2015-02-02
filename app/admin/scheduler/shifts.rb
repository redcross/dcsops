ActiveAdmin.register Scheduler::Shift, as: 'Shift' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :shift_group
  filter :county
  filter :chapter
  filter :name
  filter :abbrev
  filter :dispatch_role
  filter :shift_ends
  
  scope :all do |shifts|
    shifts.includes([:shift_groups, {:county => :chapter}, :positions]).order(:county_id, :ordinal)
  end
  scope :active, default: true do |shifts|
    shifts.where{(shift_ends == nil) | (shift_ends >= Date.current)}.includes([:shift_groups, {:county => :chapter}, :positions]).order(:county_id, :ordinal)
  end

  index do
    #column :shift_group, sortable: "scheduler_shift_groups.start_offset"
    selectable_column
    column :county
    column :name
    column :abbrev
    column 'Spreadsheet', :spreadsheet_ordinal
    column :ordinal
    column 'Positions' do |rec|
      rec.positions.map(&:name).join ", "
    end
    actions
  end

  form do |f|
    f.inputs 'Details'
    f.inputs 'Shift Groups' do
      f.input :shift_groups, as: :check_boxes, collection: Scheduler::ShiftGroup.for_chapter(f.object.county.try(:chapter))
    end
    f.inputs 'Position and County' do
      f.input :positions, as: :check_boxes, collection: f.object.county.try(:chapter).try(:positions)
      f.actions
    end
  end

  batch_action :reschedule, if: proc{AdminAbility.new(current_user).can? :create, Scheduler::Shift} do |ids|
    shifts = Scheduler::Shift.includes{chapter}.where{id.in ids}

    chapter_ids = shifts.map{|sh| sh.chapter.id}

    unless chapter_ids.uniq.size == 1
      flash[:error] = "Shifts to reschedule must all be from one chapter."
      redirect_to :back and next
    end

    chapter_id = chapter_ids.first

    params[:shifts] = shifts
    params[:shift_groups] = Scheduler::ShiftGroup.for_chapter(chapter_id)

    render action: :reschedule
  end

  collection_action :perform_reschedule, method: :post do
    reschedule = params[:reschedule]
    shifts = reschedule[:shift_ids].map{|si| Scheduler::Shift.find si }
    shifts.each{|sh| authorize! :update, sh}

    switch_date = Date.parse reschedule[:effective_date]

    shift_groups = reschedule[:shift_group_ids].map{|sgi| Scheduler::ShiftGroup.find sgi }
    new_shifts = []
    Scheduler::Shift.transaction do
      shifts.each do |sh|
        ns = sh.dup

        sh.shift_ends = switch_date
        ns.shift_begins = switch_date
        ns.shift_groups = shift_groups
        ns.position_ids = sh.position_ids

        sh.save!
        ns.save!
        new_shifts << ns
      end

      Scheduler::ShiftAssignment.where{shift_id.in(shifts) & (date >= switch_date)}.destroy_all
    end

    flash[:success] = "The shifts have been rescheduled."

    redirect_to action: :index, q: {id_in: new_shifts.map(&:id)}
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :shift_category_id, :max_signups, :county_id, :ordinal, :spreadsheet_ordinal, :dispatch_role, :shift_begins, :shift_ends, :signups_frozen_before, :min_desired_signups, :max_advance_signup, :min_advance_signup, :ignore_county, :vc_hours_type, :show_in_dispatch_console, :exclusive, :position_ids => [], :shift_group_ids => [])]
    end
  end
end
