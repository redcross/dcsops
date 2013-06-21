ActiveAdmin.register Incidents::NotificationSubscription, as: 'Notification' do
  menu parent: 'Incidents'

  controller do
    def resource_params
      request.get? ? [] : [params.require(:notification).permit(:person_id, :county_id, :notification_type)]
    end
  end

  index do
    column :person
    column :notification_type
    column :county
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :person
      f.input :county
      f.input :notification_type, collection: Incidents::NotificationSubscription::TYPES.map{|x| [x.titleize, x]}
      f.actions
    end
  end
end
