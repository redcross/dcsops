class Incidents::DispatchImporter

  MATCHERS = {
    /^\s*TAKEN: DATE: ([\d\/]+) TIME: ([\d:]+ (AM|PM))$/ => ->matches { {received_at: DateTime.strptime("#{matches[1]} #{matches[2]}", "%m/%d/%Y %I:%M %P")} },
    /^\s*DELIVERED: DATE: ([\d\/]+)\s+TIME: ([\d:]+)\s+DELIVERED TO:\s*(.*)\s*$/ => ->matches { {delivered_at: DateTime.strptime("#{matches[1]} #{matches[2]}", "%m/%d/%Y %H:%M"), :delivered_to => matches[3]} },
    /^\s*Incident#: (\d{2}-\d{3})$/ => (-> matches { {incident_number: matches[1]} }),
    /^\s*Incident: (.*)$/ => -> matches { {incident_type: matches[1]} },
    /^\s*Address: (.*)$/ => -> matches { {address: matches[1]} },
    /^\s*X-Street: (.*)$/ => -> matches { {cross_street: matches[1]} },
    /^\s*County: (.*)$/ => -> matches { {county_name: matches[1].try(:titleize)} },
    /^\s*# Displaced: (\d*)$/ => -> matches { {displaced: matches[1]} },
    /^\s*Services Requested: (.*)\n\s+: (.*)\n\s+: (.*)$/ => -> matches { {services_requested: matches[1..3].compact.map(&:strip).join(" ").strip} },
    /^\s*Agency: (.*)$/ => -> matches { {agency: matches[1]} },
    /^\s*Contact: (.*)$/ => -> matches { {contact_name: matches[1]} },
    /^\s*Phone: (.*)$/ => -> matches { {contact_phone: matches[1]} },
    /^\s*Caller ID: (.*)$/ => -> matches { {caller_id: matches[1]} },
  }

  HISTORY_MATCHER = {
      /^(\d+\/\d+\/\d+) (\d+:\d+ (AM|PM)) \[([^\]]+)\] (.*)\n\s+\(([^)]+)\) (.*)$/ => ->matches{ 
        {action_at: DateTime.strptime("#{matches[1]} #{matches[2]}", "%m/%d/%Y %I:%M %P"),
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
        handler.call(matches)
      else
        {}
      end
    end

    data = data.reduce(:merge)

    exp, handler = HISTORY_MATCHER.to_a.first
    log_items = log.split("\n\n").map do |item|
      if matches = exp.match(item)
        handler.call(matches)
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
    end
  end

end