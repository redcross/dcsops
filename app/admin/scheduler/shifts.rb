ActiveAdmin.register Scheduler::Shift, as: 'Shift' do
  menu parent: 'Scheduling'

  actions :all, except: [:destroy]

  filter :shift_group
  filter :county
  filter :name
  filter :abbrev
  filter :dispatch_role
  
  scope :all, default: true do |shifts|
    shifts.includes([:shift_groups, :county]).order(:county_id, :ordinal)
  end

  index do
    #column :shift_group, sortable: "scheduler_shift_groups.start_offset"
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

  collection_action :reschedule, method: :get do

  end

  collection_action :perform_reschedule, method: :post do
    shifts = params[:shift_ids].map{|si| Scheduler::Shift.find si }
    shifts.each{|sh| authorize! :update, sh}

    switch_date = Date.parse params[:switch_date]

    shift_groups = params[:shift_group_ids].map{|sgi| Schduler::ShiftGroup.find sgi }

    Scheduler::Shift.transaction do
      shifts.each do |sh|
        ns = sh.dup

        sh.shift_ends = shift_date
        ns.shift_begins = shift_date
        ns.shift_groups = sgi

        sh.save!
        ns.save!
      end

      Scheduler::ShiftAssignment.where{shift_id.in(shifts) & date >= switch_date}.destroy_all
    end

  end 

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :shift_category_id, :max_signups, :county_id, :ordinal, :spreadsheet_ordinal, :dispatch_role, :shift_begins, :shift_ends, :signups_frozen_before, :min_desired_signups, :max_advance_signup, :min_advance_signup, :ignore_county, :vc_hours_type, :show_in_dispatch_console, :exclusive, :position_ids => [], :shift_group_ids => [])]
    end
  end
end
