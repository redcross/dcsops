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
      safe_join(pos.role_memberships.map(&:display_name), tag(:br))
    end
    actions
  end

  controller do
    def update
      update! { url_for(action: :index)}
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :vc_regex_raw, :hidden, :chapter_id, :watchfire_role, 
        :role_memberships_attributes => [:id, :_destroy, :role_id, role_scopes_attributes: [:scope, :id, :_destroy]])]
    end
  end

  form do |f|
    f.inputs
    f.inputs do
      f.has_many :role_memberships, allow_destroy: true do |f|
        f.input :role
        f.has_many :role_scopes, allow_destroy: true do |f|
          f.input :scope
        end
      end
    end
    f.actions
  end

end
