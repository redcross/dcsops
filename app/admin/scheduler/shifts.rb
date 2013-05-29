ActiveAdmin.register Scheduler::Shift, namespace: 'scheduler_admin', as: 'Shift' do
  index do
    column :shift_group
    column :county
    column :name
    column :abbrev
    column 'Spreadsheet', :spreadsheet_ordinal
    actions
  end

  controller do
    def resource_params
      [params.require(:shift).permit(:name, :abbrev, :shift_group_id, :max_signups, :county_id, :ordinal, :spreadsheet_ordinal, :shift_begins, :shift_ends, :signups_frozen_before)]
    end
  end
end
