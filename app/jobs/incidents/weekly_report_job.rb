class Incidents::WeeklyReportJob

  def self.enqueue
    Roster::Chapter.with_incidents_report_send_automatically_value(true).each do |chapter|
      new(chapter.id).perform
    end
  end

  def initialize chapter_id
    @chapter_id = chapter_id
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
    Incidents::ReportMailer.report_for_date_range(sub.person.chapter, sub.person, sub.range_to_send).deliver
    sub.update_attribute :last_sent, current_send_date
  rescue => e
    errors << {exception: e, subscription: sub}
  end

  def current_send_date
    @current_send_date ||= begin
      seconds = chapter.time_zone.now.seconds_since_midnight
      today = chapter.time_zone.today
      if seconds < (chapter.incidents_report_send_at || 0)
        today.yesterday
      else
        today
      end
    end
  end

  def subscriptions
    Incidents::NotificationSubscription.for_type('report')
                                       .for_chapter(chapter)
                                       .to_send_on(current_send_date)
                                       .includes{person.chapter}
                                       .with_active_person
                                       .readonly(false)
  end

  def chapter
    @chapter ||= Roster::Chapter.find @chapter_id
  end

end