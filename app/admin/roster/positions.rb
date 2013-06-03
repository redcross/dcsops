ActiveAdmin.register Roster::Position, namespace: 'roster_admin', as: 'Position' do

  menu parent: 'Roster'

  filter :chapter
  filter :name

  actions :all, except: [:destroy]

  controller do
    def resource_params
      request.get? ? [] : [params.require(:position).permit(:name, :vc_regex_raw, :hidden)]
    end
  end

end
