ActiveAdmin.register Roster::Chapter, as: 'Chapter' do
  menu parent: 'Roster'

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:chapter).permit(:name, :short_name, :code, :time_zone_raw, :vc_username, :vc_password, :vc_position_filter)]
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :code
      f.input :short_name
      f.input :time_zone_raw
      f.input :vc_username
      f.input :vc_password, as: :string
      f.input :vc_position_filter
    end
    f.actions
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
