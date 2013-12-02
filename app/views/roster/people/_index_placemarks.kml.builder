collection.each do |resource|
  xml.Placemark id: resource.id do
    xml.name resource.full_name if identify_people
    xml.styleUrl "#personPlacemark"
    if resource.lat and resource.lng
      lat,lng = [resource.lat, resource.lng]
      xml.Point do
        xml.coordinates "#{resource.lng},#{resource.lat}"
      end
    end

    xml.description do
      desc = Rails.cache.fetch("person-kml-description-" + resource.cache_key) { render('person', resource: resource) }
      xml.cdata! desc
    end

    xml.visibility "1"

  end
end