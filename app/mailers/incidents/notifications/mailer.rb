module Incidents::Notifications
  class Mailer < ActionMailer::Base
    include MailerCommon
    default from: "DCSOps <incidents@dcsops.org>"

    def notify_event person, sms, event, incident, template, options=nil
      @sms = sms
      @event = event
      @incident = Incidents::IncidentPresenter.new(incident) if incident
      @template = template
      @options = options || {}

      @render_template_name = event.event
      self.send event.event

      if sms
        set_sms_delivery
        @subject = ''
        @render_template_name = "#{@render_template_name}_sms"
        recipient = person.sms_addresses.first
      else
        recipient = format_address(person)
      end

      mail to: recipient, template_name: @render_template_name, subject: @subject, from: (message.from || self.class.default[:from])
    end

    def new_incident
      @subject = "New Incident For #{@incident.county}"
    end

    def incident_dispatched
      @subject = "Incident For #{@incident.county} Dispatched"
      @render_template_name = 'new_incident'
    end

    def incident_report_filed
      @subject = "Incident Report #{@options[:is_new] ? 'Filed' : 'Updated'} For #{@incident.county}"
    end

    def incident_report_missing
      @subject = "Missing Incident Report For #{@incident.county}"
    end

    def incident_invalid
      @subject = "Incident #{@incident.incident_number} Marked Invalid"
    end

    def escalation
      @subject = "#{@template.titleize} for #{@incident.incident_number}"
    end

    helper do
      def short_maps_url(inc)
        short_url(@incident.map_url)
      end
      def short_incident_url(inc)
        short_url(incidents_incident_url(inc))
      end
    end
  end
end