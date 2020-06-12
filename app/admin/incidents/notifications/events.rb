ActiveAdmin.register Incidents::Notifications::Event, as: 'Event' do
  batch_action :destroy, false
  batch_action :edit, false

  actions :all, except: [:destroy]

  menu parent: 'Incidents'

  filter :region

  index do 
    id_column
    column :region_id
    column :name
    column :event_type
    column :event
    actions
  end

  controller do

    def collection
      @col ||= super.order(:ordinal)
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:region_id, :name, :description, :event_type, :event, :ordinal)]
    end

    after_build :set_region
    def set_region resource
      resource.region ||= current_region
    end
  end
end
