ActiveAdmin.register MOTD, as: 'MOTD' do
  menu parent: 'System'
  controller do
    def resource_params
      [params.fetch(resource_request_name, {}).permit(:region_id, :begins, :ends, :cookie_code, :html, :dialog_class, :cookie_version, :path_regex_raw)]
    end
  end

  form do |f|
    f.inputs do
      f.input :region, :include_blank => "All Regions"
      f.input :begins
      f.input :ends
      f.input :cookie_code
      f.input :html
      f.input :dialog_class
      f.input :cookie_version
      f.input :path_regex_raw
    end
    f.actions
  end

end