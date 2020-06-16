require 'csv'

class Scheduler::DirectlineMailer < ActionMailer::Base
  include MailerCommon
  default from: "DAT Scheduling <directline.export@dcsops.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #

  def export(region, start_date, end_date)
    @region = region
    start_date = start_date.to_date
    end_date = end_date.to_date
    @people = []

    attachments["shift_data.csv"] = schedule_csv(start_date, end_date)
    attachments["roster.csv"] = people_csv

    tag :export
    mail to: region.scheduler_dispatch_export_recipient, subject: "Red Cross Export", body: "Export processed at #{Time.zone.now}"
  end

  private

  def schedule_csv(start_date, end_date)
    shift_data = CSV.generate(row_sep: "\r\n") do |csv|
      csv << ["Shift Territory", "Start", "End", "On Call Person IDs"] + (1..20).map{|x| "On Call #{x}"}
      Scheduler::DispatchConfig.active.for_region(@region).includes_everything.each do |config|
        @people.concat config.backup_list
        generate_shifts_for_shift_territory(csv, @region, config, start_date, end_date)
      end
    end
  end

  def generate_shifts_for_shift_territory(csv, region, config, start_date, end_date)
    backups = config.backup_list.map(&:id)
    dispatch_shifts = config.shift_list
    return unless dispatch_shifts.present?
    dispatch_group_ids = dispatch_shifts.first.shift_time_ids

    @latest_time = nil
    all_groups = Scheduler::ShiftTime.for_region(region).order(:start_offset).to_a
    daily_groups = all_groups.select{ |grp| grp.period == 'daily' && dispatch_group_ids.include?(grp.id) }
    
    all_assignments = Scheduler::ShiftAssignment.where(shift_id: dispatch_shifts)
      .normalized_date_on_or_after(start_date)
      .where('date <= ?', end_date).group_by{|sa| [sa.date, sa.shift_id, sa.shift_time_id]}

    (start_date..end_date).each do |date|
      daily_groups.each do |daily_group|
        start_time = local_offset(region, date, daily_group.start_offset)
        end_time = local_offset(region, date, daily_group.end_offset)
        check_timing_overlap start_time, end_time
        
        current_groups = Scheduler::ShiftTime.current_groups_in_array(all_groups, start_time)
        assignments = dispatch_shifts.flat_map{|sh| current_groups.flat_map{|grp| all_assignments[[grp.start_date, sh.id, grp.id]] }.compact }

        @people.concat assignments.map(&:person)
        person_list = assignments.map(&:person_id) + backups

        csv << ([config.name, start_time.iso8601, end_time.iso8601] + person_list)
      end
    end
  end

  def check_timing_overlap start_time, end_time
    if @latest_time and @latest_time > start_time
      raise "A configuration error has occurred and shifts are overlapping: New start is #{start_time.iso8601}, last end was #{@latest_time.iso8601}"
    end
    @latest_time = end_time
  end

  def people_csv
    CSV.generate(row_sep: "\r\n") do |csv|
      csv << ["Person ID", "Last Name", "First Name", "Primary Phone", "Secondary Phone", "SMS Phone", "OnPage ID", "Email", "Primary Phone Type", "Secondary Phone Type"]
      @people.uniq.each do |person|
        phones = person.phone_order
        sms = person.phone_order(sms_only: true).first
        sms = nil if sms and sms[:carrier].pager
        csv << [person.id, person.last_name, person.first_name, format_phone(phones[0]), format_phone(phones[1]), format_phone(sms), "", "", phone_type(phones[0]), phone_type(phones[1])] 
      end
    end
  end

  def format_phone(ph)
    ph && ph[:number].gsub(/[^0-9]/, '')
  end

  def phone_type(ph)
    (ph && ph[:carrier].try(:pager)) ? 'pager' : 'phone'
  end

  def local_offset(region, date, offset)
    beginning_of_day = date.in_time_zone(region.time_zone).at_beginning_of_day
    offset_time = beginning_of_day.advance seconds: offset

    # advance counts every instant that elapses, not just calendar seconds.  so
    # when crossing DST you might end up one hour off in either direction even though
    # you just want "wall clock" time.  So if the offset of the two times is different, we
    # negate it.
    offset_time.advance( seconds: (beginning_of_day.utc_offset - offset_time.utc_offset))
  end
end
