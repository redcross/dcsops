ActiveAdmin.register Scheduler::DispatchConfig, as: 'Dispatch Configs' do
  menu parent: 'Scheduling'

  filter :region
  filter :is_active
  filter :name

  index do
    column :region
    column :name
    column :is_active
    column :shifts do |dc|
      safe_join(dc.shift_list.map(&:display_name), tag(:br))
    end
    column :backups do |dc|
      safe_join(dc.backup_list.map(&:full_name), tag(:br))
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :region, input_html: {disabled: !allow_edit_names?}
      f.input :name, input_html: {disabled: !allow_edit_names?}
      f.input :shift_territory, collection: f.object.region.try(:shift_territories), input_html: {disabled: !allow_edit_names?}
      f.input :is_active, input_html: {disabled: !allow_edit_names?}
      if f.object.region
        shifts = Scheduler::Shift.for_region(f.object.region).joins(:shift_territory).order('shift_territory.name', :name).includes(:shift_times, :shift_territory)
        f.input :shift_first, collection: shifts
        f.input :shift_second, collection: shifts
        f.input :shift_third, collection: shifts
        f.input :shift_fourth, collection: shifts
        f.input :backup_first,  as: :person_typeahead, filter: {q: {region_id_eq: f.object.region_id}}, clear: true
        f.input :backup_second, as: :person_typeahead, filter: {q: {region_id_eq: f.object.region_id}}, clear: true
        f.input :backup_third,  as: :person_typeahead, filter: {q: {region_id_eq: f.object.region_id}}, clear: true
        f.input :backup_fourth, as: :person_typeahead, filter: {q: {region_id_eq: f.object.region_id}}, clear: true
      end
    end
    f.actions
  end


  controller do
    def allow_edit_names?
      if %w(new create).include? params[:action]
        true
      else
        authorized? :update_names, resource
      end
    end
    helper_method :allow_edit_names?

    def collection
      @coll ||= super.includes_everything
    end

    def resource_params
      permitted_keys = [:backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id, :shift_first_id, :shift_second_id, :shift_third_id, :shift_fourth_id]
      permitted_keys += [:name, :region_id, :shift_territory_id, :is_active] if allow_edit_names?
      [params.fetch(resource_request_name, {}).permit(*permitted_keys)]
    end
  end
end
