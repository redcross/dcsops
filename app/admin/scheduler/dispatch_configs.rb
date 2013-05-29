ActiveAdmin.register Scheduler::DispatchConfig, namespace: 'scheduler_admin', as: 'Dispatch Config' do
  controller do
    def resource_params
      [params.require(:dispatch_config).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id)]
    end
  end
end
