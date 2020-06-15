ActiveAdmin.register Incidents::ReportSubscription, as: 'Report Subscriptions' do
  menu parent: 'Incidents'

  filter :report_type
  filter :person_first_name, as: :string
  filter :person_last_name, as: :string

  controller do
    #include ActionController::Live

    def collection
      @_collection ||= super.includes(:person)
    end

    def resource_params
      request.get? ? [] : [params.require(:notification).permit(:person_id, :shift_territory_id, :report_type, :frequency)]
    end
  end

  action_item :only => :index do
    link_to('Send Test Report', {action: :test_report}, {method: :post}) if authorized? :test_report, Incidents::ReportSubscription
  end
  action_item :only => :index do
    link_to('Send Reports', {action: :send_report}, {method: :post, data: {confirm: "This will send all notifications to region #{current_region.short_name}"}})  if authorized? :send_report, Incidents::ReportSubscription
  end

  collection_action :test_report, :method => :post do
    sub = Incidents::ReportSubscription.find_by person_id: current_user, report_type: 'report'
    if sub
      Incidents::ReportMailer.report_for_date_range(sub.scope, current_user, sub.range_to_send).deliver
    else
      flash[:error] = "You are not signed up for a report."
    end
    redirect_to({:action => :index}, {:notice => "Incident report sent to #{current_user.email}"})
  end

  collection_action :send_report, method: :post do
    begin
      response.content_type = :text
      response.stream.write "Sending subscriptions..."
      job = Incidents::WeeklyReportJob.new(current_region.id)
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
      sub.person.region_id
    end
    column :person
    column :report_type
    column :frequency
    column :shift_territory
    column :persistent
    column :last_sent
    actions
  end

  form do |f|
    f.inputs do
      f.input :person
      f.input :shift_territory
      f.input :report_type, as: :assignable_select
      f.input :frequency, as: :assignable_select
      f.input :persistent
      f.actions
    end
  end
end
