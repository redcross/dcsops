require 'csv'

class Scheduler::DirectlineMailer < ActionMailer::Base
  default from: "DAT Scheduling <arcba.vcimport@gmail.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #
  def export(chapter, start_date, end_date)
    @chapter = chapter
    people = []

    shift_data = CSV.generate do |csv|
      csv << ["County", "Start", "End", "On Call Person IDs"]
      chapter.counties.each do |county|
        config = Scheduler::DispatchConfig.for_county county
        next unless config.is_active
        people = people + config.backup_list
        (start_date..end_date).each do |date|
          Scheduler::ShiftGroup.where(chapter_id: chapter, period: 'daily').order(:start_offset).each do |group|
            shifts = group.shifts.where(county_id: county).where("dispatch_role is not null").order(:dispatch_role)
            shifts = shifts.map{|sh| Scheduler::ShiftAssignment.where(date: date, shift_id: sh).first }.compact
            people = people + shifts.map(&:person)
            csv << ([county.name, local_offset(date, group.start_offset), local_offset(date, group.end_offset)] + shifts.map(&:person_id) + config.backup_list.map(&:id))
          end
        end
      end
    end

    person_data = CSV.generate do |csv|
      csv << ["Person ID", "Last Name", "First Name", "Primary Phone", "Secondary Phone", "SMS Phone", "OnPage ID", "Email"]
      people.uniq.each do |person|
        phones = person.phone_order
        csv << [person.id, person.last_name, person.first_name, format_phone(phones[0]), format_phone(phones[1]), format_phone(person.phone_order(sms_only: true).first), "", ""] 
      end
    end

    attachments["shift_data.csv"] = shift_data
    attachments["roster.csv"] = person_data

    mail to: "jlaxson@mac.com", subject: "Red Cross Export - Chapter #{chapter.code}", body: "Export processed at #{Time.zone.now}"
  end

  private
  def format_phone(ph)
    ph && ph[:number].gsub(/[^0-9]/, '')
  end
  def local_offset(date, offset)
    #date.in_time_zone.at_beginning_of_day.advance( seconds: offset).iso8601

    beginning_of_day = date.in_time_zone(@chapter.time_zone).at_beginning_of_day
    offset_time = beginning_of_day.advance seconds: offset

    # advance counts every instant that elapses, not just calendar seconds.  so
    # when crossing DST you might end up one hour off in either direction even though
    # you just want "wall clock" time.  So if the offset of the two times is different, we
    # negate it.
    offset_time.advance( seconds: (beginning_of_day.utc_offset - offset_time.utc_offset)).iso8601
  end
end
