class Incidents::DispatchImporter

  def self.parse_ampm(chapter, date, time)
    m = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}) (AM|PM)/.match("#{date} #{time}")
    hr = m[4].to_i
    hr -= 12 if hr == 12
    hr += 12 if m[6] == 'PM'
    chapter.time_zone.parse "#{m[3]}-#{m[1]}-#{m[2]} #{hr}:#{m[5]}"
  end

  def self.parse_24h(chapter, date, time)
    m = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})/.match("#{date} #{time}")
    chapter.time_zone.parse "#{m[3]}-#{m[1]}-#{m[2]} #{m[4]}:#{m[5]}:#{m[6]}"
  end

  MATCHERS = {
    /^\s*TAKEN: DATE: ([\d\/]+) TIME: ([\d:]+ (AM|PM))$/ => ->(matches,chapter){ {received_at: parse_ampm(chapter, matches[1], matches[2])} },
    /^\s*DELIVERED: DATE: ([\d\/]+)\s+TIME: ([\d:]+ (AM|PM))\s*\nDELIVERED TO:\s*(.*)\s*(INCIDENT.*)?$/ => ->(matches,chapter){ {delivered_at: parse_ampm(chapter, matches[1], matches[2]), :delivered_to => matches[4]} },
    /^\s*Incident#: (\d{2}-\d{3})$/ => (->(matches,chapter){ {incident_number: matches[1].strip} }),
    /^\s*Incident: (.*)$/ => ->(matches,chapter){ {incident_type: matches[1].strip} },
    /^\s*Address: (.*)$/ => ->(matches,chapter){ {address: matches[1].strip} },
    /^\s*X-Street: (.*)$/ => ->(matches,chapter){ {cross_street: matches[1].strip} },
    /^\s*County: (.*)$/ => ->(matches,chapter){ {county_name: matches[1].try(:titleize)} },
    /^\s*# Displaced: (\d*)$/ => ->(matches,chapter){ {displaced: matches[1]} },
    /^\s*Services Requested: (.*)\n\s+: (.*)\n\s+: (.*)$/ => ->(matches,chapter){ {services_requested: matches[1..3].compact.map(&:strip).join(" ").strip} },
    /^\s*Agency: (.*)$/ => ->(matches,chapter){ {agency: matches[1].strip} },
    /^\s*Contact: (.*)$/ => ->(matches,chapter){ {contact_name: matches[1].strip} },
    /^\s*Phone: (.*)$/ => ->(matches,chapter){ {contact_phone: matches[1].strip} },
    /^\s*Caller ID: (.*)$/ => ->(matches,chapter){ {caller_id: matches[1].strip} },
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

  def map_log_items(log, incident, details)
    if log.received_at
      received = incident.event_logs.find_or_initialize_by(event: 'dispatch_received')
      received.event_time = log.received_at
      received.message = details.gsub(/-+/, "").gsub(/\n{3,}/, "\n\n")
      received.save!
    end

    if log.delivered_at
      relayed = incident.event_logs.find_or_initialize_by(event: 'dispatch_relayed')
      relayed.event_time = log.delivered_at
      relayed.message = "Delivered to: #{log.delivered_to}"
      relayed.save!
    end

    incident.event_logs.where(event: 'dispatch_note').delete_all
    log.log_items.each do |item|
      next if item.action_type =~ /^SMS Message/
      msg = "#{item.action_type}: #{item.recipient}\nResult: #{item.result}"
      incident.event_logs.create! event: 'dispatch_note', event_time: item.action_at, message: msg
    end
  end

  def update_incident(log_object)
    if log_object.incident.nil?
      if inc = Incidents::Incident.find_by( chapter_id: @chapter, incident_number: log_object.incident_number)
        log_object.incident = inc
        geocode_incident(log_object, inc)
        log_object.save
        
        return false
      else
        inc_date = log_object.received_at ? log_object.received_at.in_time_zone(@chapter.time_zone).to_date : @chapter.time_zone.today
        log_object.create_incident! incident_number: log_object.incident_number, 
                                            chapter: @chapter,
                                               date: inc_date,
                                               area: @chapter.counties.where{name == log_object.county_name}.first
        log_object.save!
        inc = log_object.incident
        geocode_incident(log_object, inc)
        return true
      end
    end
  end

  def run_matchers(matchers, text)
    matchers.map do |exp, handler|
      if matches = exp.match(text)
        handler.call(matches, @chapter)
      else
        {}
      end
    end.select(&:present?).reduce(:merge)
  end

  def geocode_incident(log_object, incident)
    return if Rails.env.test?

    incident.address = log_object.address
    res = Geokit::Geocoders::GoogleGeocoder3.geocode "#{log_object.address}, #{log_object.county_name} County, CA, USA"
    if res
      incident.lat = res.lat
      incident.lng = res.lng
    end
  rescue Geokit::TooManyQueriesError
    # Not the end of the world
  rescue => e
    Raven.capture_exception(e)
  end

  def import_data(chapter, body)
    @chapter = chapter

    details, log = body.split("============ Message Dispatch History ===================")

    data = run_matchers MATCHERS, body
    log_items = log.split("\n\n").map {|item_text| run_matchers HISTORY_MATCHER, item_text}


    Incidents::DispatchLog.transaction do
      if data[:incident_number].present?
        log_object = Incidents::DispatchLog.where(chapter_id: chapter.id, incident_number: data[:incident_number]).first_or_initialize
        log_object.update_attributes data

        log_object.log_items.destroy_all
        log_object.log_items = log_items.select(&:present?).map{|attrs| Incidents::DispatchLogItem.new attrs}
        log_object.save!

        created_incident = update_incident(log_object)
        map_log_items(log_object, log_object.incident, details)

        if created_incident
          Incidents::IncidentCreated.new(log_object.incident).save
        else
          Incidents::DispatchLogUpdated.new(log_object).save
        end
      end
    end
  end

end