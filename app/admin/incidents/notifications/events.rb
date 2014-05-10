ActiveAdmin.register Incidents::Notifications::Event, as: 'Event' do
  batch_action :destroy, false
  batch_action :edit, false

  actions :all, except: [:destroy]

  menu parent: 'Incidents'

  index do 
    id_column
    column :chapter_id
    column :name
    column :event_type
    column :event
    default_actions
  end

  controller do

    def collection
      @col ||= super.order{ordinal}
    end

    def resource_params
      request.get? ? [] : [params.require(:person).permit(:first_name, :last_name, 
        county_memberships_attributes: [:id, :_destroy, :persistent, :county_id],
        position_memberships_attributes: [:id, :_destroy, :persistent, :position_id])]
    end
  end
end
