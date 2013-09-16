ActiveAdmin.register ApiClient, as: 'Api Client' do
  menu parent: 'System'

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end

  index do
    column :name
    column :app_token
  end

  controller do
    def resource_params
      return [] if request.get?
      [params.require('api_client').permit(:name)]
    end
  end
end