ActiveAdmin.register Roster::Person, namespace: 'scheduler_admin', as: 'Person' do
  batch_action :destroy, false
  batch_action :edit, false

  index do
    column :id
    column :name_last_first

    column "Number of Shifts" do |person|
      Scheduler::ShiftAssignment.where(person: person).where('date <= ?', Date.current).count
    end

    column "Last Shift" do |person|
      Scheduler::ShiftAssignment.where(person: person).where('date <= ?', Date.current).first.try(:date)
    end

    column "Next Shift" do |person|
      Scheduler::ShiftAssignment.where(person: person).where('date >= ?', Date.current).first.try(:date)
    end

    default_actions
  end

  filter :first_name
  filter :last_name

  controller do
    def resource_params
      [params.require(:dispatch_config).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id)]
    end
  end
end
