collection.includes(:dat_incident, :all_responder_assignments, team_lead: :person).find_each(batch_size: 100) do |resource|
  xml.Placemark id: resource.id do
    xml.name resource.incident_number + " " + (resource.humanized_incident_type || "")
    xml.styleUrl "##{resource.incident_type}"
    if resource.lat and resource.lng
      lat,lng = [resource.lat, resource.lng]
      xml.Point do
        xml.coordinates "#{resource.lng},#{resource.lat}"
      end
    end

    xml.description do
      xml.cdata! render('incident', resource: resource)
    end

    xml.visibility "1"

  end
end