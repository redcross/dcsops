ActiveAdmin.register Logistics::Vehicle, as: 'Vehicle' do
  menu parent: 'Logistics'

  form do |f|
    f.inputs do
      f.input :chapter
      f.input :name
      f.input :category, as: :assignable_select_admin
      f.input :address
      f.input :city
      f.input :state
      f.input :zip
    end
    f.actions
  end

  controller do
    after_build :set_chapter
    def set_chapter resource
      resource.chapter ||= current_chapter
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:chapter_id, :name, :category, :address, :city, :state, :zip, :lat, :lng)]
    end
  end
end
