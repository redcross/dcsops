require 'csv'
require 'base64'

class Scheduler::WatchfireMailer < ActionMailer::Base
  default from: "DAT Scheduling <arcba.vcimport@gmail.com>"

  DAY_SHIFT = 7..18

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #
  def export(chapter)
    @chapter = chapter

    chapter.counties.where{name != "Chapter"}.each do |county|
      scope = Roster::Person.includes{positions}.joins{[counties, positions]}.where{(counties.id==county.id) & (positions.watchfire_role != nil) & (positions.watchfire_role != 'dshr')}.uniq
      file = generate_file_for_people(scope)
      add_file("#{county.name}.csv",file)
    end

    scope = Roster::Person.includes{positions}.where{(positions.watchfire_role != nil) & (positions.watchfire_role != 'dshr')}.uniq
    add_file("Chapter DAT.csv", generate_file_for_people(scope))

    scope = Roster::Person.joins{positions}.where{(positions.watchfire_role != nil) & (positions.watchfire_role == 'dshr')}.uniq
    add_file("Chapter DSHR.csv", generate_file_for_people(scope))

    mail to: "jlaxson@mac.com", subject: "ARCBA Watchfire Export", body: ""
  end

  def add_file(name, content)
    attachments[name] = {content_type: "text/csv", content_transfer_encoding: "base64", content: Base64.encode64(content)}
  end

  def generate_file_for_people(scope)
    CSV.generate do |csv|
      csv << ["ID Number", "Name", "OpenID", "Address", "Lat", "Lng", "Phone 1", "Phone 2", "SMS Phone", "Roles"] + (0..23).map{|h| Scheduler::FlexSchedule.days.map{|d| "avail_#{d}_%02d00" % h}}.flatten

      scope.each do |person|
        phones = person.phone_order.map{|ph| ph[:number].gsub(/\D+/, "")}
        sms_phone = person.phone_order(sms_only: true).map{|ph| ph[:number].gsub(/\D+/, "")}.first
        arr = [person.id, person.full_name, roster_openid_user_url(person), person.full_address, person.lat, person.lng ,phones[0], phones[1], sms_phone]

        arr << person.positions.map(&:watchfire_role).compact.join("|")

        flex = Scheduler::FlexSchedule.where{id == person.id}.first
        days = Scheduler::FlexSchedule.days

        arr += (0..23).map do |h| 
          days.each_with_index.map do |d, idx| 
            if flex
              day = (h < DAY_SHIFT.first) ? days[(idx-1)] : d
              !!flex.available(day, DAY_SHIFT.include?(h) ? "day" : "night")
            end
          end
        end.flatten

        csv << arr
      end
    end
  end
end