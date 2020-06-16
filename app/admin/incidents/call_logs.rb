ActiveAdmin.register Incidents::CallLog, as: 'Call Log' do
  menu parent: 'Incidents'

  actions :index, :show
  filter :region

  index do
    id_column
    column :call_type
    column :region
    column :call_start
    column(:incident) { |cl| cl.incident.try :incident_number }
    actions
  end

  controller do
    def collection 
      @coll ||= super.preload(:incident, :region)
    end
  end

end
