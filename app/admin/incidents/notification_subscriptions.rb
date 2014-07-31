ActiveAdmin.register Incidents::NotificationSubscription, as: 'Notification' do
  menu parent: 'Incidents'

  filter :notification_type

  controller do
    #include ActionController::Live

    def collection
      @_collection ||= super.includes{person}
    end

    def resource_params
      request.get? ? [] : [params.require(:notification).permit(:person_id, :county_id, :notification_type, :frequency)]
    end
  end

  action_item :only => :index do
    link_to('Send Test Report', {action: :test_report}, {method: :post}) if authorized? :test_report, Incidents::NotificationSubscription
  end
  action_item :only => :index do
    link_to('Send Daily Report', {action: :send_report}, {method: :post, data: {confirm: "This will send all notifications to chapter #{current_chapter.short_name}"}})  if authorized? :send_report, Incidents::NotificationSubscription
  end

  collection_action :test_report, :method => :post do
    sub = Incidents::NotificationSubscription.find_by person_id: current_user, notification_type: 'report'
    Incidents::ReportMailer.report_for_date_range(current_chapter, current_user, sub.range_to_send).deliver
    redirect_to({:action => :index}, {:notice => "Incident report sent to #{current_user.email}"})
  end

  collection_action :send_report, method: :post do
    begin
      response.content_type = :text
      response.stream.write "Sending subscriptions..."
      job = Incidents::WeeklyReportJob.new(current_chapter.id)
      job.perform
      response.stream.write "Sent to #{job.count} people.\n"
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
    actions
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
