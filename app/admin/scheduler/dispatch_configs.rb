ActiveAdmin.register Scheduler::DispatchConfig, as: 'Dispatch Configs' do
  menu parent: 'Scheduling'

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
      f.input :chapter
      f.input :name
      f.input :county, collection: f.object.chapter.try(:counties)
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
    def collection
      @coll ||= super.includes_everything
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:is_active, :backup_first_id, :backup_second_id, :backup_third_id, :backup_fourth_id, :name, :chapter_id, :shift_first_id, :shift_second_id, :shift_third_id, :shift_fourth_id)]
    end
  end
end
