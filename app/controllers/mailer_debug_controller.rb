class MailerDebugController < ApplicationController

  def report
    chapter = params[:chapter_id] && Roster::Chapter.find(params[:chapter_id]) || current_chapter
    person = params[:person_id] && Roster::Person.find(params[:person_id]) || current_user

    start_date = params[:start_date] && Date.parse(params[:end_date]) || chapter.time_zone.today.at_beginning_of_week.last_week
    end_date = params[:end_date] && Date.parse(params[:end_date]) || chapter.time_zone.today.at_beginning_of_week

    mail = Incidents::ReportMailer.report_for_date_range(chapter, person, start_date..end_date)
    render text: mail.parts.last.body, content_type: :html
  end

end