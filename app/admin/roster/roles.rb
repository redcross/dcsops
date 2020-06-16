ActiveAdmin.register Roster::Role, as: 'Role' do
  menu parent: 'Roster'

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :grant_name)]
    end

    def collection
      @coll ||= apply_scopes(super).preload(role_memberships: [:position, :role_scopes])
    end
  end

  index do
    column :name
    column :grant_name
    column :positions do |role|
      safe_join(role.role_memberships.map{|pm| "#{pm.position.name if pm.position} (#{pm.role_scopes.map(&:scope).join ','})"}, tag(:br))
    end
    actions
  end

  form do |f|
    f.inputs
    f.actions
  end

  filter :name
  filter :grant_name
end
