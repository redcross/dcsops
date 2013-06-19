ActiveAdmin.register MOTD, as: 'MOTD' do
  controller do
    def resource_params
      request.get? ? [] : [params.require(:motd).permit(:chapter_id, :begins, :ends, :cookie_code, :html, :dialog_class, :cookie_version, :path_regex_raw)]
    end
  end
end