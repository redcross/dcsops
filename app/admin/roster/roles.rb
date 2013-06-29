ActiveAdmin.register Roster::Role, as: 'Role' do
  menu parent: 'Roster'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:role).permit(:name, :grant_name, role_scopes: [:scope, :_destroy])]
    end

    def collection
      super.includes{role_scopes}
    end
  end

  index do
    column :name
    column :grant_name
    column :scopes do |obj|
      obj.role_scopes.map(&:scope).join ","
    end
    default_actions
  end

  form do |f|
    f.inputs

    f.has_many :role_scopes do |f|
      f.input :scope
      f.input :_destroy, as: :boolean, label: "Remove"
    end

    f.actions
  end
end
