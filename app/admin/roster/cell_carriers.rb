ActiveAdmin.register Roster::CellCarrier, as: 'Cell Carrier' do
  menu parent: 'Roster'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:cell_carrier).permit(:name, :sms_gateway, :pager)]
    end
  end
end
