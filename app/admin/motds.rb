ActiveAdmin.register MOTD, as: 'MOTD' do
  menu parent: 'System'
  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:region_id, :begins, :ends, :cookie_code, :html, :dialog_class, :cookie_version, :path_regex_raw)]
    end
  end
end