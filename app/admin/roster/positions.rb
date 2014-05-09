ActiveAdmin.register Roster::Position, as: 'Position' do

  menu parent: 'Roster'

  filter :chapter
  filter :name
  filter :hidden
  filter :abbrev

  actions :all, except: [:destroy]

  index do
    id_column
    column :chapter_id
    column :name
    #column :vc_regex_raw
    column :hidden
    column :roles do |pos|
      safe_join(pos.roles.map(&:name), tag(:br))
    end
    actions
  end

  controller do
    def update
      update! { url_for(action: :index)}
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :vc_regex_raw, :hidden, :chapter_id, :watchfire_role, :role_ids => [])]
    end
  end

  form do |f|
    f.inputs
    f.inputs do
      f.input :roles, as: :check_boxes, collection: (f.object.chapter && f.object.chapter.roles.sort_by(&:name))
    end
    f.actions
  end

end
