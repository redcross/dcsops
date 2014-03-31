ActiveAdmin.register Incidents::Disaster, as: 'Disaster' do
  menu parent: 'Incidents'

  actions :index, :show

end
