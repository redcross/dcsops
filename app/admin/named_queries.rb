ActiveAdmin.register NamedQuery, as: 'Named Query' do
  menu parent: 'System'
  controller do
    def resource_params
      request.get? ? [] : [params.require(:named_query).permit(:name, :token, :controller, :action, :parameters)]
    end
  end
end