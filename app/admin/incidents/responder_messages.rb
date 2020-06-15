ActiveAdmin.register Incidents::ResponderMessage, as: 'Responder Message' do
  menu parent: 'Incidents'

  actions :index, :show

  filter :region
  filter :message

  index do
    column("CID") { |msg| msg.region_id }
    column("Person") { |msg| msg.person.try :full_name }
    column(:incident) { |msg| msg.incident.try :incident_number }
    column :direction
    column :message
    column :acknowledged
    column :created_at
  end

  controller do
    def collection
      @collection ||= super.includes(:person, :incident)
    end
  end

end
