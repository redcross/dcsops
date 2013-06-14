ActiveAdmin.register Roster::Chapter, as: 'Chapter' do
  menu parent: 'Roster'

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:chapter).permit(:name, :short_name, :code, :time_zone_raw)]
    end
  end
end
