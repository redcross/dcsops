module Incidents::IncidentsListHelper
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
      distance_of_time mean, include_seconds: false
    end
  end
end