ActiveAdmin.register Roster::Position, namespace: 'roster_admin', as: 'Position' do

  menu parent: 'Roster'

  filter :chapter
  filter :name

end
