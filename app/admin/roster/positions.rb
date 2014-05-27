ActiveAdmin.register Roster::Position, as: 'Position' do

  menu parent: 'Roster'

  filter :chapter
  filter :name
  filter :hidden
  filter :abbrev

  actions :all, except: [:destroy]

  controller do
    def create
      create! { redirect_to :back }
    end

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
