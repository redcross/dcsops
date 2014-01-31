ActiveAdmin.register Scheduler::DispatchConfig, as: 'Dispatch Configs' do
  menu parent: 'Scheduling'

  filter :is_active
  filter :county
  filter :name

  index do
    column :name
    column :county
    column :is_active
    column :backup_first
    column :backup_second
    column :backup_third
    column :backup_fourth
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :county
      if f.object.county
        f.input :backup_first,  as: :person_typeahead, filter: {chapter_id_eq: f.object.county.chapter_id}
        f.input :backup_second, as: :person_typeahead, filter: {chapter_id_eq: f.object.county.chapter_id}
        f.input :backup_third,  as: :person_typeahead, filter: {chapter_id_eq: f.object.county.chapter_id}
        f.input :backup_fourth, as: :person_typeahead, filter: {chapter_id_eq: f.object.county.chapter_id}
      end
    end
    f.actions
  end


  controller do
    def resource_params
      [params.require(:dispatch_configs).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id, :name, :county_id)]
    end
  end
end
