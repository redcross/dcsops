class Incidents::DispatchImporter

  def self.parse_ampm(chapter, date, time)
    m = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}) (AM|PM)/.match("#{date} #{time}")
    hr = m[4].to_i
    hr += 12 if m[6] == 'PM'
    chapter.time_zone.parse "#{m[3]}-#{m[1]}-#{m[2]} #{hr}:#{m[5]}"
  end

  def self.parse_24h(chapter, date, time)
    m = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})/.match("#{date} #{time}")
    chapter.time_zone.parse "#{m[3]}-#{m[1]}-#{m[2]} #{m[4]}:#{m[5]}:#{m[6]}"
  end

  MATCHERS = {
    /^\s*TAKEN: DATE: ([\d\/]+) TIME: ([\d:]+ (AM|PM))$/ => ->(matches,chapter){ {received_at: parse_ampm(chapter, matches[1], matches[2])} },
    /^\s*DELIVERED: DATE: ([\d\/]+)\s+TIME: ([\d:]+ (AM|PM))\s*\nDELIVERED TO:\s*(.*)\s*$/ => ->(matches,chapter){ {delivered_at: parse_ampm(chapter, matches[1], matches[2]), :delivered_to => matches[4]} },
    /^\s*Incident#: (\d{2}-\d{3})$/ => (->(matches,chapter){ {incident_number: matches[1]} }),
    /^\s*Incident: (.*)$/ => ->(matches,chapter){ {incident_type: matches[1]} },
    /^\s*Address: (.*)$/ => ->(matches,chapter){ {address: matches[1]} },
    /^\s*X-Street: (.*)$/ => ->(matches,chapter){ {cross_street: matches[1]} },
    /^\s*County: (.*)$/ => ->(matches,chapter){ {county_name: matches[1].try(:titleize)} },
    /^\s*# Displaced: (\d*)$/ => ->(matches,chapter){ {displaced: matches[1]} },
    /^\s*Services Requested: (.*)\n\s+: (.*)\n\s+: (.*)$/ => ->(matches,chapter){ {services_requested: matches[1..3].compact.map(&:strip).join(" ").strip} },
    /^\s*Agency: (.*)$/ => ->(matches,chapter){ {agency: matches[1]} },
    /^\s*Contact: (.*)$/ => ->(matches,chapter){ {contact_name: matches[1]} },
    /^\s*Phone: (.*)$/ => ->(matches,chapter){ {contact_phone: matches[1]} },
    /^\s*Caller ID: (.*)$/ => ->(matches,chapter){ {caller_id: matches[1]} },
  }

  HISTORY_MATCHER = {
      /^(\d+\/\d+\/\d+) (\d+:\d+ (AM|PM)) \[([^\]]+)\] (.*)\n\s+\(([^)]+)\) (.*)$/ => ->(matches,chapter){ 
        {action_at: parse_ampm(chapter, matches[1], matches[2]),
             action_type: matches[4].strip,
             recipient: matches[5].strip,
             operator: matches[6].strip,
             result: matches[7].strip
        } },
    }

  def import_data(chapter, body)
    details, log = body.split("============ Message Dispatch History ===================")

    data = MATCHERS.map do |exp, handler|
      if matches = exp.match(details)
        handler.call(matches, chapter)
      else
        {}
      end
    end

    data = data.reduce(:merge)

    exp, handler = HISTORY_MATCHER.to_a.first
    log_items = log.split("\n\n").map do |item|
      if matches = exp.match(item)
        handler.call(matches, chapter)
      else
        {}
      end
    end

    if data[:incident_number].present?
      log_object = Incidents::DispatchLog.where(chapter_id: chapter.id, incident_number: data[:incident_number]).first_or_initialize
      log_object.update_attributes data

      log_object.log_items.destroy_all
      log_object.log_items = log_items.select(&:present?).map{|attrs| Incidents::DispatchLogItem.new attrs}
      log_object.save!

      if log_object.incident.nil?
        if inc = Incidents::Incident.find_by( chapter_id: chapter, incident_number: log_object.incident_number)
          log_object.incident = inc
          log_object.save
        else
          log_object.create_incident! incident_number: log_object.incident_number, 
                                              chapter: chapter,
                                                 date: log_object.received_at.in_time_zone(chapter.time_zone).to_date,
                                               county: chapter.counties.where{name == log_object.county_name}.first
          Incidents::IncidentCreated.new(log_object.incident).save
        end
      end

      if log_object.incident
        # Map the log items to incident events
        inc = log_object.incident

        received = inc.event_logs.find_or_initialize_by(event: 'dispatch_received')
        received.event_time = log_object.received_at
        received.message = details.gsub(/-+/, "").gsub(/\n{3,}/, "\n\n")
        received.save!

        if log_object.delivered_at
          relayed = inc.event_logs.find_or_initialize_by(event: 'dispatch_relayed')
          relayed.event_time = log_object.delivered_at
          relayed.message = "Delivered to: #{log_object.delivered_to}"
          relayed.save!
        end

        inc.event_logs.where(event: 'dispatch_note').delete_all
        log_object.log_items.each do |item|
          next if item.action_type =~ /^SMS Message/
          msg = "#{item.action_type}: #{item.recipient}\nResult: #{item.result}"
          inc.event_logs.create! event: 'dispatch_note', event_time: item.action_at, message: msg
        end
      end


      Incidents::DispatchLogUpdated.new(log_object).save
    end
  end

end