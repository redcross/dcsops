ActiveAdmin.register Logistics::Vehicle, as: 'Vehicle' do
  menu parent: 'Logistics'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:vehicle).permit(:chapter_id, :name, :category, :address, :city, :state, :zip, :lat, :lng)]
    end
  end
end
