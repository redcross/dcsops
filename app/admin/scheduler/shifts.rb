ActiveAdmin.register Scheduler::Shift, as: 'Shift' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :shift_time
  filter :shift_territory, collection: Roster::ShiftTerritory.where(enabled: true)
  filter :region
  filter :name
  filter :abbrev
  filter :shift_ends
  
  scope :all do |shifts|
    shifts.includes([:shift_times, {:shift_territory => :region}, :positions]).order(:shift_territory_id, :ordinal)
  end
  scope :active, default: true do |shifts|
    shifts.where(shift_ends: nil).or(shifts.where(shift_ends: Date.current..DateTime::Infinity.new)).includes([:shift_times, {:shift_territory => :region}, :positions]).order(:shift_territory_id, :ordinal)
  end

  index do
    #column :shift_time, sortable: "scheduler_shift_times.start_offset"
    selectable_column
    column :shift_territory
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
    f.inputs 'Details' do
      f.input :shift_territory, collection: Roster::ShiftTerritory.where(enabled: true)
      f.input :shift_category
      f.input :name
      f.input :abbrev
      f.input :max_signups
      f.input :ordinal
      f.input :spreadsheet_ordinal
      f.input :shift_begins
      f.input :shift_ends
      f.input :signups_frozen_before
      f.input :max_advance_signup
      f.input :signups_available_before
      f.input :min_desired_signups
      f.input :ignore_shift_territory
      f.input :min_advance_signup
      f.input :exclusive
      f.input :vc_hours_type
      f.input :show_in_dispatch_console
    end
    f.inputs 'Shift Times' do
      f.input :shift_times, as: :check_boxes, collection: Scheduler::ShiftTime.for_region(f.object.shift_territory.try(:region)).where(enabled: true)
    end
    f.inputs 'Position and Shift Territory' do
      f.input :positions, as: :check_boxes, collection: f.object.shift_territory.try(:region).try(:positions)
      f.actions
    end
  end

  batch_action :reschedule, if: proc{AdminAbility.new(current_user).can? :create, Scheduler::Shift} do |ids|
    shifts = Scheduler::Shift.includes(:region).where(id: ids)

    region_ids = shifts.map{|sh| sh.region.id}

    unless region_ids.uniq.size == 1
      flash[:error] = "Shifts to reschedule must all be from one region."
      redirect_back fallback_location: root_path and next
    end

    region_id = region_ids.first

    params[:shifts] = shifts
    params[:shift_times] = Scheduler::ShiftTime.for_region(region_id)

    render action: :reschedule
  end

  collection_action :perform_reschedule, method: :post do
    reschedule = params[:reschedule]
    shifts = reschedule[:shift_ids].map{|si| Scheduler::Shift.find si }
    shifts.each{|sh| authorize! :update, sh}

    switch_date = Date.parse reschedule[:effective_date]

    shift_times = reschedule[:shift_time_ids].map{|sgi| Scheduler::ShiftTime.find sgi }
    new_shifts = []
    Scheduler::Shift.transaction do
      shifts.each do |sh|
        ns = sh.dup

        sh.shift_ends = switch_date
        ns.shift_begins = switch_date
        ns.shift_times = shift_times
        ns.position_ids = sh.position_ids

        sh.save!
        ns.save!
        new_shifts << ns
      end

      Scheduler::ShiftAssignment.where(shift_id: shifts, date: switch_date..DateTime::Infinity.new).destroy_all
    end

    flash[:success] = "The shifts have been rescheduled."

    redirect_to action: :index, q: {id_in: new_shifts.map(&:id)}
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :shift_category_id, :max_signups, :shift_territory_id, :ordinal, :spreadsheet_ordinal, :shift_begins, :shift_ends, :signups_frozen_before, :min_desired_signups, :signups_available_before, :max_advance_signup, :min_advance_signup, :ignore_shift_territory, :vc_hours_type, :show_in_dispatch_console, :exclusive, :position_ids => [], :shift_time_ids => [])]
    end
  end
end
