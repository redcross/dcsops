ActiveAdmin.register HomepageLink, as: 'Homepage Link' do
  menu parent: 'System'

  index do
    column :id
    column :chapter
    column :name
    column :group
    column :description
    column :icon
    column "Target" do |link|
      link.url.present? ? link.url : link.file_file_name
    end
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :chapter
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
      f.input :roles, as: :check_boxes, collection: Roster::Role.where{chapter_id == f.object.chapter}
    end
  end

  controller do
    after_build :set_chapter
    def set_chapter resource
      resource.chapter ||= current_chapter
    end

    def resource_params
      request.get? ? [] : [params.require(:homepage_link).permit(:name, :description, :file, :icon, :url, :ordinal, :group, :group_ordinal)]
    end
  end
end