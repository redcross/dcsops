module Incidents::Notifications
  class Mailer < ActionMailer::Base
    include MailerCommon
    default from: "DCSOps <incidents@dcsops.org>"
    helper ApplicationHelper

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
        sms!
        @subject = ''
        @render_template_name = "#{@render_template_name}_sms"
        recipient = person.sms_addresses
      else
        recipient = format_address(person)
      end

      reply_opts = {}
      if @incident.region.incidents_notifications_reply_to.present?
        reply_opts[:reply_to] = @incident.region.incidents_notifications_reply_to
      end

      msg = mail({to: recipient, template_name: @render_template_name, subject: @subject, from: (message.from || self.class.default[:from])}.merge reply_opts)
      if sms
        @_message = SmsEmailGroup.new(msg)
      end
    end

    def initial_incident_report_extra_contact address, incident, options={}
      @incident = incident
      @options = options

      initial_incident_report

      mail to: address, template_name: "initial_incident_report", subject: @subject, from: (message.from || self.class.default[:from])
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

    def incident_missing_report
      @subject = "Missing Incident Report For #{@incident.county}"
    end

    def incident_invalid
      @subject = "Incident #{@incident.incident_number} Marked Invalid"
    end

    def escalation
      @subject = "#{@template.titleize} for #{@incident.incident_number}"
    end

    def initial_incident_report
      @subject = "Initial Incident Report for #{@incident.incident_number} #{@incident.humanized_incident_type} in #{@incident.region.name}"
      attachments[@options[:attachment_filename]] = @options[:attachment_data]
    end

    helper do
      def short_maps_url(inc)
        short_url(@incident.map_url)
      end
      def short_incident_url(inc)
        short_url(incidents_region_incident_url(inc.region, inc))
      end
      def region_message(inc)
        inc.region.incidents_notifications_custom_message.try(:presence)
      end
    end
  end
end