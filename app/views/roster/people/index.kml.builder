xml.instruct!

xml.kml ns: 'http://www.opengis.net/kml/2.2' do
  xml.Document do
    xml.Style id: 'personPlacemark' do
      xml.IconStyle do
        xml.Icon do
          xml.href asset_url('map-icons/person-icon.png')
        end
      end
      xml.LabelStyle do
        xml.scale "0.7"
      end
    end
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
          xml.cdata! render('person', resource: resource)
        end

        xml.visibility "1"

      end
    end
  end
end