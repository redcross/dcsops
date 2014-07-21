class Incidents::DispatchImporter
  class_attribute :geocoder
  self.geocoder = AutoGeocode

  def parse_ampm(date, time)
    m = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}) (AM|PM)/.match("#{date} #{time}")
    hr = m[4].to_i
    hr -= 12 if hr == 12
    hr += 12 if m[6] == 'PM'
    @chapter.time_zone.parse "#{m[3]}-#{m[1]}-#{m[2]} #{hr}:#{m[5]}"
  end

  #def parse_24h(date, time)
  #  m = /(\d{2})\/(\d{2})\/(\d{4}) (\d{2}):(\d{2}):(\d{2})/.match("#{date} #{time}")
  #  @chapter.time_zone.parse "#{m[3]}-#{m[1]}-#{m[2]} #{m[4]}:#{m[5]}:#{m[6]}"
  #end

  def data_matchers
    {
      /^\s*TAKEN: DATE: ([\d\/]+) TIME: ([\d:]+ (AM|PM))$/ => ->(matches){ {received_at: parse_ampm(matches[1], matches[2])} },
      /^\s*DELIVERED: DATE: ([\d\/]+)\s+TIME: ([\d:]+ (AM|PM))\s*\nDELIVERED TO:\s*(.*)\s*(INCIDENT.*)?$/ => ->(matches){ {delivered_at: parse_ampm(matches[1], matches[2]), :delivered_to => matches[4]} },
      /^\s*Incident#: (\d{2}-\d{3})$/ => (:incident_number),
      /^\s*Incident: (.*)$/ => :incident_type,
      /^\s*Address: (.*)$/ => :address,
      /^\s*X-Street: (.*)$/ => :cross_street,
      /^\s*County: (.*)$/ => ->(matches){ {county_name: matches[1].try(:titleize)} },
      /^\s*State: (.*)$/ => :state,
      /^\s*# Displaced: (\d*)$/ => :displaced,
      /^\s*Services Requested: (.*)\n\s+: (.*)\n\s+: (.*)$/ => ->(matches){ {services_requested: matches[1..3].compact.map(&:strip).join(" ")} },
      /^\s*Agency: (.*)$/ => :agency,
      /^\s*Contact: (.*)$/ => :contact_name,
      /^\s*Phone: (.*)$/ => :contact_phone,
      /^\s*Caller ID: (.*)$/ => :caller_id,
    }
  end

  def history_matchers
    {
      /^(\d+\/\d+\/\d+) (\d+:\d+ (AM|PM)) \[([^\]]+)\] (.*)\n\s+\(([^)]+)\) (.*)$/ => ->(matches){ 
        {action_at: parse_ampm(matches[1], matches[2]),
             action_type: matches[4],
             recipient: matches[5],
             operator: matches[6],
             result: matches[7]
        } },
    }
  end

  def map_log_item(incident, time, event, message)
    if time
      event_log = incident.event_logs.find_or_initialize_by(event: event)
      event_log.event_time = time
      event_log.message = message
      event_log.save!
    end
  end

  def map_log_items(log, incident, details)
    map_log_item incident, log.received_at, 'dispatch_received', details#
    map_log_item incident, log.delivered_at, 'dispatch_relayed', "Delivered to: #{log.delivered_to}"

    incident.event_logs.where(event: 'dispatch_note').delete_all
    log.log_items.each do |item|
      next if item.action_type =~ /^SMS Message/
      incident.event_logs.create! event: 'dispatch_note', event_time: item.action_at, message: item.description
    end
  end

  def incident_date_for(log_object)
    log_object.received_at ? log_object.received_at.in_time_zone(@chapter.time_zone).to_date : @chapter.time_zone.today
  end

  def update_incident(log_object)
    return unless log_object.incident.nil?
    if inc = Incidents::Incident.find_by( chapter_id: @chapter, incident_number: log_object.incident_number)
      log_object.incident = inc
      
      created = false
    else
      area = @chapter.counties.find_by(name: log_object.county_name)
      area ||= @chapter.counties.find_by name: 'Region'
      area ||= @chapter.counties.first
      log_object.build_incident incident_number: log_object.incident_number, 
                                         chapter: @chapter,
                                            date: incident_date_for(log_object),
                                          county: log_object.county_name,
                                            area: area,
                                          status: 'open'
      
      created = true
    end

    geocode_incident(log_object, log_object.incident)
    log_object.incident.save!
    log_object.save!
    

    created
  end

  def run_matchers(matchers, text)
    matchers.map do |exp, handler|
      if matches = exp.match(text)
        vals = case handler
        when Symbol
          {handler => matches[1]}
        else
          handler.call(matches)
        end
        strip_hash_values vals
      end
    end.select(&:present?).reduce(:merge)
  end

  def strip_hash_values hash
    hash.update(hash){|k, v| v.respond_to?(:strip) ? v.strip : v}
  end

  def geocode_incident(log_object, incident)
    incident.address = log_object.address
    res = self.class.geocoder.geocode "#{log_object.address}, #{log_object.state || "CA"}, USA"
    incident.take_location_from res if res.success?
  rescue Geokit::Geocoders::TooManyQueriesError
    # Not the end of the world
  end

  def update_log_object(attrs, log_items)
    log_object = Incidents::DispatchLog.find_or_initialize_by(chapter_id: @chapter.id, incident_number: attrs[:incident_number])
    log_object.update_attributes attrs

    log_object.log_items.destroy_all
    log_object.log_items = log_items.select(&:present?).map{|item_attrs| Incidents::DispatchLogItem.new item_attrs}
    log_object.save!

    log_object
  end

  def clean_body body
    body.gsub(/--+/, "").gsub(/\n{3,}/, "\n\n")
  end

  def parse_body body
    details, log = clean_body(body).split("============ Message Dispatch History ===================")

    data = run_matchers self.data_matchers, body
    log_items = log.split("\n\n").map {|item_text| run_matchers self.history_matchers, item_text}
    log_object = update_log_object data, log_items

    return unless data[:incident_number].present?

    created_incident = update_incident(log_object)
    map_log_items(log_object, log_object.incident, details)

    send_notification(log_object, created_incident)
  end

  def send_notification(log_object, created)
    if created
      Incidents::Notifications::Notification.create_for_event log_object.incident, 'new_incident'
    else
      Incidents::Notifications::Notification.create_for_event log_object.incident, 'incident_dispatched'
    end
  end

  def import_data(chapter, body)
    @chapter = chapter

    Incidents::DispatchLog.transaction do      
      parse_body body
    end
  end

end