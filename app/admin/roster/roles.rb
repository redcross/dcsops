ActiveAdmin.register Roster::Role, as: 'Roles' do
  menu parent: 'Roster'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:role).permit(:name)]
    end
  end
end
