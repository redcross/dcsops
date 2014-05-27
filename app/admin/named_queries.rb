ActiveAdmin.register NamedQuery, as: 'Named Query' do
  menu parent: 'System'

  show do
    attributes_table do
      row :id
      row :name
      row :token
      row :parameters
      row :controller
      row :action
      row :created_at
      row :updated_at
    end

    attributes_table do
      row "URL" do |nq|
        begin
          url_for(controller: nq.controller.underscore.gsub(/_controller$/, ''), action: nq.action, query_name: nq.name, query_token: nq.token, only_path: false)
        rescue ActionController::UrlGenerationError => e
          "Cannot generate URL: #{e}"
        end
      end
    end
  end

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:name, :token, :controller, :action, :parameters)]
    end
  end
end