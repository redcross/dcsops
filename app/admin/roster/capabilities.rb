ActiveAdmin.register Roster::Capability, as: 'Capability' do
  menu parent: 'Roster'

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :grant_name)]
    end

    def collection
      @coll ||= apply_scopes(super).preload(capability_memberships: [:position, :capability_scopes])
    end
  end

  index do
    column :name
    column :grant_name
    column :positions do |capability|
      safe_join(capability.capability_memberships.map{|pm| "#{pm.position.name if pm.position} (#{pm.capability_scopes.map(&:scope).join ','})"}, tag(:br))
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
