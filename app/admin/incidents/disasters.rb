ActiveAdmin.register Incidents::Disaster, as: 'Disaster' do
  menu parent: 'Incidents'

  actions :index, :show

  filter :dr_number
  filter :fiscal_year
  filter :name

end
