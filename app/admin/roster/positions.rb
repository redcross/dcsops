ActiveAdmin.register Roster::Position, as: 'Position' do

  menu parent: 'Roster'

  filter :region
  filter :name
  filter :hidden
  filter :abbrev

  actions :all, except: [:destroy]

  index do
    id_column
    column :region
    column :name
    column :hidden
    column :capabilities do |pos|
      safe_join(pos.capability_memberships.map(&:display_name), tag(:br))
    end
    actions
  end

  show do
    default_main_content
    attributes_table do
      row("Number of Members") { resource.people.count }
    end
    vc_positions = resource.vc_positions.uniq
    panel "Matched VC Positions" do
      table_for vc_positions do
        column("Name") { |r| r[:name] }
      end
    end
  end

  controller do
    def update
      update! { url_for(action: :index)}
    end

    after_build :set_region
    def set_region resource
      resource.region ||= current_region
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :abbrev, :hidden, :region_id,
        :capability_memberships_attributes => [:id, :_destroy, :capability_id, capability_scopes_attributes: [:scope, :id, :_destroy]])]
    end
  end

  form do |f|
    f.inputs
    f.inputs do
      f.has_many :capability_memberships, allow_destroy: true do |f|
        f.input :capability
        f.has_many :capability_scopes, allow_destroy: true do |f|
          f.input :scope
        end
      end
    end
    f.actions
  end

end
