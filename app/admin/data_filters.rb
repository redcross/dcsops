ActiveAdmin.register DataFilter do
  menu parent: 'System'

  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:model, :field, :pattern_raw)]
    end
  end
end