module Incidents::IncidentsHelper

  def edit_link panel, title="(edit)", opts={}
    if inline_editable?
      url = edit_incidents_incident_dat_path(resource, panel_name: panel)
      link_to title, '#', {data: {edit_panel: url}}.merge(opts)
    else
      ""
    end
  end

  def passthrough_edit_link panel, title, opts={}
    if inline_editable?
      edit_link panel, title, opts
    else
      title
    end
  end

  def version_ignore_fields(version)
    %w(id created_at updated_at incident_id) + case version.item_type
    when 'Incidents::Incident', 'Incidents::DatIncident'
      %w(lat lng)
    when 'Incidents::EventLog'
      %w(person_id)
    else
      []
    end
  end

  def format_change_value(base, name, val)
    case val
    when DateTime, Time, ActiveSupport::TimeWithZone
      val.in_time_zone.to_s :date_time # An ApplicationController filter automatically sets the current time zone for each request
    when String
      if name == 'cac_number' and val.present?
        "xxxx-xxxx-xxxx-" + val[-4..-1]
      elsif ['services', 'languages'].include? name and val.present?
        YAML.load(val).map(&:titleize).to_sentence
      else
        val
      end
    else val
    end
  end

  def always_show_fields(version)
    case version.item_type
    when 'Incidents::EventLog'
      %w(event)
    when 'Incidents::Case'
      %w(last_name unit)
    else
      []
    end
  end

  def counties_for_menu(collection)
    collection.select{[county, state]}.where{county != ''}.order(:state, :county).uniq.map{|row| "#{row.county}, #{row.state}" }.to_a.uniq{|s| s.downcase}
  end

  def neighborhoods_for_menu(collection)
    collection.unscope(:order, :offset, :limit).order(:neighborhood).uniq.pluck :neighborhood
  end

  def num val
    number_with_delimiter val.try(:round), precision: 0
  end

  def assistance_totals(collection)
    collection.joins{cases}.select{
      [count(cases.id).as(:num_cases),
        sum(cases.total_amount).as(:total_assistance)
      ]
    }.group("incidents_cases.total_amount = 0.0").to_a
  end

  def total_miles_driven(collection)
    collection.joins{responder_assignments.person}.where{responder_assignments.role.in(Incidents::ResponderAssignment::ON_SCENE_ROLES)}
      .where{{responder_assignments: {person: sift(:with_position)}} }
      .select{
        sum(least(degrees(acos(cos(radians(responder_assignments.person.lat)) *
                               cos(radians(lat)) *
                               cos(radians(responder_assignments.person.lng) - radians(lng)) +
                               sin(radians(responder_assignments.person.lat)) *
                               sin(radians(lat)))) * Geokit::Mappable::MILES_PER_LATITUDE_DEGREE * 2, 50)).as(:distance)
      }.take.distance
  end

  def average_response_time(collection)
    logs_start = Incidents::EventLog.where{(event.in(['dispatch_received', 'dispatch_note', 'dat_received', 'dispatch_relayed', 'responders_identified'])) & (incident_id == incidents_incidents.id)}.order{event_time}.select{event_time}.limit(1).to_sql
    logs_end = Incidents::EventLog.where{(event.in(['dat_on_scene'])) & (incident_id == incidents_incidents.id)}.order{event_time}.select{event_time}.limit(1).to_sql
    durations = collection.select(
      "extract(epoch from (#{logs_end}) - (#{logs_start})) AS duration"
    ).to_a.map(&:duration).select{|dur| dur && dur > 10.minutes && dur < 8.hours}

    if durations.present?
      mean = durations.sum / durations.size
      seconds = mean % 3600
      minutes = (seconds / 60).floor
      hours = ((mean - seconds) / 3600).floor
      "#{pluralize hours, 'hour'} #{pluralize minutes, 'minute'}"
    end
  end
end
