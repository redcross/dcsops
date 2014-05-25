ActiveAdmin.register Incidents::ResponderMessage, as: 'Responder Message' do
  menu parent: 'Incidents'

  actions :index, :show

  index do
    column("CID") { |msg| msg.chapter_id }
    column("Person") { |msg| msg.person.full_name }
    column :incident
    column :direction
    column :message
    column :acknowledged
    column :created_at
  end

end
