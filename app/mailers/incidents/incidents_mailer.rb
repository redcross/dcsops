class Incidents::IncidentsMailer < ActionMailer::Base
  include MailerCommon

  default from: "DCSOps <incidents@dcsops.org>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.incidents.incidents_mailer.no_incident_report.subject
  #
  def no_incident_report(incident, recipient)
    @incident = incident

    tag :incidents, :no_incident_report
    mail to: format_address(recipient), subject: "Missing Incident Report For #{incident.area_name}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.incidents.incidents_mailer.orphan_cas.subject
  #
  def orphan_cas
    @greeting = "Hi"

    tag :incidents, :orphan_cas
    mail to: "to@example.org"
  end

  def new_incident(incident, recipient)
    @incident = incident
    tag :incidents, :incidents_notification, :new_incident
    mail to: format_address(recipient), subject: "New Incident For #{incident.area_name}"
  end

  def incident_dispatched(incident, recipient)
    @incident = incident
    tag :incidents, :incidents_notification, :incident_dispatched
    mail to: format_address(recipient), subject: "Incident For #{incident.area_name} Dispatched", template_name: 'new_incident'
  end

  def incident_report_filed(incident, recipient, is_new=true)
    @incident = incident
    tag :incidents, :incidents_notification, :incident_report_filed
    mail to: format_address(recipient), subject: "Incident Report #{is_new ? 'Filed' : 'Updated'} For #{incident.area_name}"
  end

  def incident_invalid(incident, recipient)
    @incident = incident
    tag :incidents, :incidents_notification, :incident_invalid
    mail to: format_address(recipient), subject: "Incident #{incident.incident_number} Marked Invalid"
  end

end
