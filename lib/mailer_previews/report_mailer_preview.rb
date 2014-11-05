class ReportMailerPreview < ActionMailer::Preview
  def weekly_report
    start = 3.months.ago.to_date
    Incidents::ReportMailer.report_for_date_range(Incidents::Scope.find(1), Roster::Person.find(1704), (start)..(start+7))
  end

  def daily_report
    start = 3.months.ago.to_date
    Incidents::ReportMailer.report_for_date_range(Incidents::Scope.find(1), Roster::Person.find(1704), (start)..(start+1))
  end
end