class Incidents::WeeklyReportJob

  def self.enqueue
    Incidents::Scope.with_report_send_automatically_value(true).each do |region|
      new(region.id).perform
    end
  end

  def initialize scope_id
    @scope_id = scope_id
  end

  def perform
    @num_subscriptions = 0
    subscriptions.each do |sub|
      deliver_subscription sub
      @num_subscriptions += 1
    end
  end

  def count
    @num_subscriptions
  end

  def errors
    @errors ||= []
  end

  private 

  def deliver_subscription sub
    Incidents::ReportMailer.report_for_date_range(sub.scope, sub.person, sub.range_to_send).deliver
    sub.update_attribute :last_sent, current_send_date
  rescue => e
    errors << {exception: e, subscription: sub}
  end

  def current_send_date
    @current_send_date ||= begin
      seconds = scope.time_zone.now.seconds_since_midnight
      today = scope.time_zone.today
      if seconds < (scope.report_send_at || 0)
        today.yesterday
      else
        today
      end
    end
  end

  def subscriptions
    Incidents::ReportSubscription.for_type('report')
                                 .for_scope(scope)
                                 .to_send_on(current_send_date)
                                 .includes(person: :region)
                                 .with_active_person
                                 .readonly(false)
  end

  def scope
    @scope ||= Incidents::Scope.find @scope_id
  end

end