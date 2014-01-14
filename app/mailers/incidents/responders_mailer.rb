class Incidents::RespondersMailer < ActionMailer::Base
  include MailerCommon
  default from: "DCSOps <incidents@dcsops.org>"

  def assign_email(assignment)
    @assignment = assignment
    @person = assignment.person
    @incident = assignment.incident

    mail to: format_address(assignment.person), subject: 'DCSOps Incident Assignment'
  end

  def assign_sms(assignment)
    @assignment = assignment
    @person = assignment.person
    @incident = assignment.incident

    mail to: assignment.person.sms_addresses, subject: ''
  end
  use_sms_relay :assign_sms

  helper do
    def maps_url(inc)
      "https://maps.google.com/maps?q=#{inc.lat}+#{inc.lng}+" + Rack::Utils.escape("(#{inc.incident_number} #{inc.address})")
    end

    def short_maps_url(inc)
      url = "https://maps.google.com/maps?q=#{inc.lat}+#{inc.lng}+"
      Bitly.client.shorten(url).short_url
    end
  end
end
