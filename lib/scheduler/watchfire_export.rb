require 'csv'
require 'base64'
require 'net/https'

class Scheduler::WatchfireExport
  include Rails.application.routes.url_helpers

  DAY_SHIFT = 7..18

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.scheduler.reminders_mailer.email_invite.subject
  #
  def export(chapter)
    @chapter = chapter
    return unless chapter.id==1

    people = Roster::Person.where{chapter_id==my{chapter}}.includes{positions}

    chapter.counties.where{name != "Chapter"}.each do |county|
      scope = people.joins{[counties, positions]}.where{(counties.id==county.id) & (positions.watchfire_role != nil) & (positions.watchfire_role != 'dshr')}.uniq
      upload_for_people_to_organization(scope, "#{chapter.short_name} - #{county.name}")
    end

    scope = people.where{(positions.watchfire_role != nil) & (positions.watchfire_role != "") & (positions.watchfire_role != 'dshr')}.uniq
    upload_for_people_to_organization(scope, "#{chapter.short_name} - DAT")

    scope = people.where{(positions.watchfire_role != nil) & (positions.watchfire_role != "") & (positions.watchfire_role == 'dshr')}.uniq
    upload_for_people_to_organization(scope, "#{chapter.short_name} - GAP")
  end

  def url
    URI(ENV['WATCHFIRE_URL'])
  end

  def username
    ENV['WATCHFIRE_CREDENTIALS'].split(":").first
  end

  def password
    ENV['WATCHFIRE_CREDENTIALS'].split(":").last
  end

  def identity_url(user)
    Rails.application.routes.url_helpers.roster_openid_user_url(user, host: "www.dcsops.org")
  end

  def upload_for_people_to_organization(scope, org_name)
    file = generate_file_for_people(scope)

    puts "==== Uploading #{org_name} ===="
    puts "SQL: #{scope.to_sql}"
    puts "File: #{file}"

    http = Net::HTTP.new(url.host, url.port)
    #http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    req = Net::HTTP::Post.new("#{url.path}?organization=#{CGI.escape org_name}")
    req.body = file
    req.content_type = "text/csv"
    req.basic_auth username, password
    puts "Credentials: #{username}:#{password}"
    puts "URL: #{req.path}"
    puts "Headers: #{req.to_s}"
    resp = http.request req
    puts resp.body
  end

  def generate_file_for_people(scope)
    CSV.generate do |csv|
      csv << ["ID Number", "Name", "OpenID", "Address", "Lat", "Lng", "Phone 1", "Phone 2", "SMS Phone", "Roles"] + (0..23).map{|h| Scheduler::FlexSchedule.days.map{|d| "avail_#{d}_%02d00" % h}}.flatten

      scope.each do |person|
        phones = person.phone_order.map{|ph| ph[:number].gsub(/\D+/, "")}
        sms_phone = person.phone_order(sms_only: true).map{|ph| ph[:number].gsub(/\D+/, "")}.first
        arr = [person.id, person.full_name, identity_url(person), person.full_address, person.lat, person.lng ,phones[0], phones[1], sms_phone]

        arr << person.positions.map(&:watchfire_role).compact.select(&:present?).join("|")

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