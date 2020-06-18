ActiveAdmin.register Logistics::Vehicle, as: 'Vehicle' do
  menu parent: 'Logistics'

  form do |f|
    f.inputs do
      f.input :region
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
    after_build :set_region
    def set_region resource
      resource.region ||= current_region
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:region_id, :name, :category, :address, :city, :state, :zip, :lat, :lng)]
    end
  end
end
