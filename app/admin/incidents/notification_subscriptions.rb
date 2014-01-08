ActiveAdmin.register Incidents::NotificationSubscription, as: 'Notification' do
  menu parent: 'Incidents'

  filter :notification_type

  controller do
    def collection
      @_collection ||= super.includes{person}
    end

    def resource_params
      request.get? ? [] : [params.require(:notification).permit(:person_id, :county_id, :notification_type)]
    end
  end

  action_item :only => :index do
    link_to('Send Test Report', {action: :test_report}, {method: :post})
  end
  collection_action :test_report, :method => :post do
    Incidents::ReportMailer.report(current_chapter, current_user).deliver
    redirect_to({:action => :index}, {:notice => "Incident report sent to #{current_user.email}"})
  end

  index do
    column 'CID' do |sub|
      sub.person.chapter_id
    end
    column :person
    column :notification_type
    column :frequency
    column :county
    column :persistent
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :person
      f.input :county
      f.input :notification_type, as: :assignable_select
      f.input :frequency, as: :assignable_select
      f.input :persistent
      f.actions
    end
  end
end
