ActiveAdmin.register Logistics::Vehicle, as: 'Vehicle' do
  menu parent: 'Logistics'

  controller do
    after_build :set_chapter
    def set_chapter resource
      resource.chapter ||= current_chapter
    end

    def resource_params
      request.get? ? [] : [params.require(:vehicle).permit(:chapter_id, :name, :category, :address, :city, :state, :zip, :lat, :lng)]
    end
  end
end
