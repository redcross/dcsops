ActiveAdmin.register Scheduler::DispatchConfig, as: 'Dispatch Configs' do
  menu parent: 'Scheduling'

  filter :chapter
  filter :is_active
  filter :name

  index do
    column :chapter
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
      f.input :chapter, input_html: {disabled: !allow_edit_names?}
      f.input :name, input_html: {disabled: !allow_edit_names?}
      f.input :county, collection: f.object.chapter.try(:counties), input_html: {disabled: !allow_edit_names?}
      f.input :is_active, input_html: {disabled: !allow_edit_names?}
      if f.object.chapter
        shifts = Scheduler::Shift.for_chapter(f.object.chapter).joins{county}.order{[county.name, name]}.includes{[shift_groups, county]}
        f.input :shift_first, collection: shifts
        f.input :shift_second, collection: shifts
        f.input :shift_third, collection: shifts
        f.input :shift_fourth, collection: shifts
        f.input :backup_first,  as: :person_typeahead, filter: {q: {chapter_id_eq: f.object.chapter_id}}, clear: true
        f.input :backup_second, as: :person_typeahead, filter: {q: {chapter_id_eq: f.object.chapter_id}}, clear: true
        f.input :backup_third,  as: :person_typeahead, filter: {q: {chapter_id_eq: f.object.chapter_id}}, clear: true
        f.input :backup_fourth, as: :person_typeahead, filter: {q: {chapter_id_eq: f.object.chapter_id}}, clear: true
      end
    end
    f.actions
  end


  controller do
    def allow_edit_names?
      authorized? :update_names, resource
    end
    helper_method :allow_edit_names?

    def collection
      @coll ||= super.includes_everything
    end

    def resource_params
      permitted_keys = [:backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id, :shift_first_id, :shift_second_id, :shift_third_id, :shift_fourth_id]
      permitted_keys += [:name, :chapter_id, :county_id, :is_active] if allow_edit_names?
      [params.fetch(resource_request_name, {}).permit(*permitted_keys)]
    end
  end
end
