ActiveAdmin.register HomepageLink, as: 'Homepage Link' do
  menu parent: 'System'

  index do
    column :id
    column :region
    column :name
    column :group
    column :description
    column :icon
    column "Target" do |link|
      link.url.present? ? link.url : link.file_file_name
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :region
      f.input :name
      f.input :file, as: :file
      f.input :description
      f.input :icon
      f.input :url
      f.input :ordinal
      f.input :group
      f.input :group_ordinal
      f.actions
    end
    f.inputs 'Roles' do
      f.has_many :roles, allow_destroy: true do |f|
        f.input :role_scope
      end
    end
    f.actions
  end

  controller do
    after_build :set_region
    def set_region resource
      resource.region ||= current_region
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :description, :file, :icon, :url, :ordinal, :group, :group_ordinal, roles_attributes: [:role_scope, :id, :_destroy])]
    end
  end
end