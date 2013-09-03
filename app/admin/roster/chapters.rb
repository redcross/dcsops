ActiveAdmin.register Roster::Chapter, as: 'Chapter' do
  menu parent: 'Roster'

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:chapter).permit(:name, :short_name, :code, :time_zone_raw, :vc_username, :vc_password)]
    end
  end

  index do
    column :id
    column :name
    column :code
    column :short_name
    column :time_zone_raw
    column :vc_username
    default_actions
  end
end
