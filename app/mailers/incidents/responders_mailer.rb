class Incidents::RespondersMailer < ActionMailer::Base
  include MailerCommon
  default from: "DCSOps <incidents@dcsops.org>"

  def assign_email(assignment)
    @assignment = assignment
    subject = "DCSOps Incident Assignment - #{incident.incident_number} as #{assignment.humanized_role}"
    mail to: format_address(assignment.person), subject: subject
  end

  def assign_sms(assignment)
    @assignment = assignment

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

  attr_reader :assignment
  helper_method :assignment, :person, :incident

  def person
    assignment.person
  end

  def incident
    assignment.incident
  end
end
