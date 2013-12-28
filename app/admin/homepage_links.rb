ActiveAdmin.register HomepageLink, as: 'Homepage Link' do
  menu parent: 'System'

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
    def resource_params
      request.get? ? [] : [params.require(:homepage_link).permit!]
    end
  end
end