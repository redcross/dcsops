ActiveAdmin.register Roster::Chapter, namespace: 'roster_admin', as: 'Chapter' do
  menu parent: 'Roster'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:chapter).permit(:name, :short_name, :code, :time_zone_raw)]
    end
  end
end
