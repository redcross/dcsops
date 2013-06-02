ActiveAdmin.register Roster::CellCarrier, namespace: 'roster_admin', as: 'Cell Carrier' do
  menu parent: 'Roster'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:cell_carrier).permit(:name, :sms_gateway)]
    end
  end
end
