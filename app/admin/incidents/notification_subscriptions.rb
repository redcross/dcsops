ActiveAdmin.register Incidents::NotificationSubscription, as: 'Notification' do
  menu parent: 'Incidents'

  filter :notification_type

  controller do
    include ActionController::Live

    def collection
      @_collection ||= super.includes{person}
    end

    def resource_params
      request.get? ? [] : [params.require(:notification).permit(:person_id, :county_id, :notification_type, :frequency)]
    end
  end

  action_item :only => :index do
    link_to('Send Test Report', {action: :test_report}, {method: :post})
  end
  action_item :only => :index do
    link_to('Send Daily Report', {action: :send_report}, {method: :post, data: {confirm: "This will send all notifications to chapter #{current_chapter.short_name}"}})
  end

  collection_action :test_report, :method => :post do
    sub = Incidents::NotificationSubscription.find_by person_id: current_user, notification_type: 'report'
    Incidents::ReportMailer.report_for_date_range(current_chapter, current_user, sub.range_to_send).deliver
    redirect_to({:action => :index}, {:notice => "Incident report sent to #{current_user.email}"})
  end

  collection_action :send_report, method: :post do
    begin
      chapter = current_chapter
      today = chapter.time_zone.today
      subscriptions = Incidents::NotificationSubscription.for_type('report').for_chapter(chapter).to_send_on(today).includes{person.chapter}.with_active_person.readonly(false)
      response.content_type = :text
      subscriptions.each do |sub|
        Incidents::ReportMailer.report_for_date_range(sub.person.chapter, sub.person, sub.range_to_send).deliver
        sub.update_attribute :last_sent, today
        response.stream.write "Sent to #{sub.person.email}\n"
      end
      response.stream.write "Sent to #{subscriptions.count} people.\n"
    rescue => e
      response.stream.write "An exception occurred while sending, please try again.\n"
      response.stream.write e.to_s + "\n"
      raise e
    ensure
      response.stream.close
    end
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
    column :last_sent
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
