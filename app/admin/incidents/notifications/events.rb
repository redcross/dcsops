ActiveAdmin.register Incidents::Notifications::Event, as: 'Event' do
  batch_action :destroy, false
  batch_action :edit, false

  actions :all, except: [:destroy]

  menu parent: 'Incidents'

  filter :chapter

  index do 
    id_column
    column :chapter_id
    column :name
    column :event_type
    column :event
    actions
  end

  controller do

    def collection
      @col ||= super.order{ordinal}
    end

    def resource_params
      [params.fetch(resource_request_name, {}).permit(:chapter_id, :name, :description, :event_type, :event, :ordinal)]
    end

    after_build :set_chapter
    def set_chapter resource
      resource.chapter ||= current_chapter
    end
  end
end
