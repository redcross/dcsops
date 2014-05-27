ActiveAdmin.register Roster::CellCarrier, as: 'Cell Carrier' do
  menu parent: 'Roster'

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :sms_gateway, :pager)]
    end
  end
end
