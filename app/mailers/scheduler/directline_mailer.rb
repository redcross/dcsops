require 'csv'

class Scheduler::DirectlineMailer < ActionMailer::Base
  include MailerCommon
  default from: "DAT Scheduling <directline.export@arcbadat.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #

  def self.run_for_chapter_if_needed(chapter, force=true, window=2)
    end_window = chapter.time_zone.now.advance days: window
    Scheduler::ShiftAssignment.transaction do
      if force or Scheduler::ShiftAssignment.joins{shift}.where{(shift.dispatch_role != nil) & (date <= end_window.to_date) & (not(synced))}.exists?
        self.run_for_chapter(chapter)
        Scheduler::ShiftAssignment.joins{shift.shift_group}.where{shift.shift_group.chapter_id==chapter}.update_all synced: true
      end
    end
  end

  def self.run_for_chapter(chapter)
    log = ImportLog.create! controller: self.to_s, name: "DirectlineExport", start_time: Time.now

    day = chapter.time_zone.today
    self.export(chapter, day - 1, day + 60).deliver

    log.result = 'success'
    log.runtime = (Time.now - log.start_time)
    log.save!
  rescue => e
    log.result = 'exception'
    log.update_from_exception(e)
    log.runtime = (Time.now - log.start_time)
    log.save!

    raise e
  end

  def export(chapter, start_date, end_date)
    start_date = start_date.to_date
    end_date = end_date.to_date
    @chapter = chapter
    @people = []

    attachments["shift_data.csv"] = schedule_csv(chapter, start_date, end_date)
    attachments["roster.csv"] = people_csv

    tag :export
    mail to: "redcross@directlineinc.com", subject: "Red Cross Export - Chapter #{chapter.code}", body: "Export processed at #{Time.zone.now}"
  end

  private

  def schedule_csv(chapter, start_date, end_date)
    shift_data = CSV.generate(row_sep: "\r\n") do |csv|
      csv << ["County", "Start", "End", "On Call Person IDs"] + (1..20).map{|x| "On Call #{x}"}
      chapter.counties.each do |county|
        config = Scheduler::DispatchConfig.for_county county
        next unless config.is_active
        @people = @people + config.backup_list
        generate_shifts_for_county(csv, chapter, county, start_date, end_date, config.backup_list.map(&:id))
      end
    end
  end

  def generate_shifts_for_county(csv, chapter, county, start_date, end_date, backups)
    latest_time = nil
    (start_date..end_date).each do |date|
      Scheduler::ShiftGroup.where(chapter_id: chapter, period: 'daily').includes(:shifts).where{shifts.dispatch_role != nil}.order(:start_offset).each do |group|
        shifts = group.shifts.where(county_id: county).where("dispatch_role is not null").order(:dispatch_role)
        shifts = shifts.map{|sh| Scheduler::ShiftAssignment.where(date: date, shift_id: sh).first }.compact

        @people = @people + shifts.map(&:person)
        person_list = shifts.map(&:person_id) + backups

        start_time = local_offset(date, group.start_offset)
        end_time = local_offset(date, group.end_offset)

        if latest_time and latest_time > start_time
          raise "A configuration error has occurred and shifts are overlapping"
        end
        latest_time = local_offset(date, group.end_offset)

        csv << ([county.name, start_time, end_time] + person_list)
      end
    end
  end

  def people_csv
    CSV.generate(row_sep: "\r\n") do |csv|
      csv << ["Person ID", "Last Name", "First Name", "Primary Phone", "Secondary Phone", "SMS Phone", "OnPage ID", "Email", "Primary Phone Type", "Secondary Phone Type"]
      @people.uniq.each do |person|
        phones = person.phone_order
        csv << [person.id, person.last_name, person.first_name, format_phone(phones[0]), format_phone(phones[1]), format_phone(person.phone_order(sms_only: true).first), "", "", phone_type(phones[0]), phone_type(phones[1])] 
      end
    end
  end

  def format_phone(ph)
    ph && ph[:number].gsub(/[^0-9]/, '')
  end

  def phone_type(ph)
    (ph && ph[:carrier].try(:pager)) ? 'pager' : 'phone'
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
