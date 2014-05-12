module Incidents::Notifications
  class Notification
    def self.create(*args)
      new(*args).send
    end

    def self.create_for_event incident, event_name, options=nil
      event = Event.for_chapter(incident.chapter).for_type('event').for_event_name(event_name).first
      create incident, event, options if event
    end

    def initialize(incident, event, options = nil)
      @incident = incident
      @event = event
      @options = options
    end

    def send
      roles = roles_for_event(@event)
      messages = plan_messages(roles)
      messages.each do |msg|
        deliver_message msg
      end
    end

    def triggers_for_event event
      event.triggers.includes{role.role_scopes}
    end

    def roles_for_event event
      triggers = triggers_for_event(event).select{|tr| match_scope tr.role }
      triggers.map { |tr| {template: tr.template, use_sms: tr.use_sms, people: tr.role.members}}
    end

    def match_scope role
      if role.role_scopes.blank?
        true
      else
        incident_county = "#{@incident.county}, #{@incident.state}".downcase
        role.role_scopes.any? { |scope|
          case scope.level
          when 'region' then true
          when 'county' then scope.value.downcase == incident_county
          else false
          end
        }
      end
    end

    def plan_messages roles
      messages = roles.flat_map do |data|
        data[:people].map do |person|
          data.slice(:template, :use_sms).merge(person: person)
        end
      end

      # Uniq messages, preferring certain templates
      messages.group_by{|d| d[:person] }.map do |person, data|
        if data.length > 1
          sms = data.map{|d| d[:use_sms] }.reduce(&:|)
          template = data.map{|d| d[:template] }.sort_by{|tmpl| Trigger::TEMPLATES.index tmpl }.last
          {person: person, use_sms: sms, template: template}
        else
          data.first
        end
      end
    end

    def deliver_message opts
      Mailer.notify_event(opts[:person], false, @event, @incident, opts[:template],@options).deliver
      if opts[:use_sms] and (sms = opts[:person].sms_addresses).present?
        Mailer.notify_event(opts[:person], true, @event, @incident, opts[:template],@options).deliver
      end
    end
  end
end