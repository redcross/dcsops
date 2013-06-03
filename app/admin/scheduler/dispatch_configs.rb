ActiveAdmin.register Scheduler::DispatchConfig, namespace: 'scheduler_admin', as: 'Dispatch Config' do
  menu parent: 'Scheduling'

  filter :county

  actions :all, except: [:destroy, :create, :new]

  index do
    column :county
    column :is_active
    column :backup_first
    column :backup_second
    column :backup_third
    column :backup_fourth
    default_actions
  end

  controller do
    def resource_params
      [params.require(:dispatch_config).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id)]
    end
  end
end
