ActiveAdmin.register Partners::Partner, as: 'Partner' do
  menu parent: 'Partners'

  #actions :all, except: [:destroy]

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:region_id, :name, :address1, :address2, :city, :state, :zip)]
    end
  end
end
