ActiveAdmin.register Roster::County, namespace: 'roster_admin', as: 'County' do

  menu parent: 'Roster'

  filter :chapter
  filter :name

end
