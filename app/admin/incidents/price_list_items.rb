ActiveAdmin.register Incidents::PriceListItem, as: 'Price List Item' do
  menu parent: 'Incidents'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:price_list_item).permit!]
    end
  end
end
