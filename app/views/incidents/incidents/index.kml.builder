xml.instruct!

xml.kml ns: 'http://www.opengis.net/kml/2.2' do
  xml.Document do
    xml.Style id: 'fire' do
      xml.IconStyle do
        xml.Icon do
          xml.href asset_url('map-icons/fire.png')
        end
      end
      xml.LabelStyle do
        xml.scale "0.7"
      end
    end

    xml.Style id: 'flood' do
      xml.IconStyle do
        xml.Icon do
          xml.href asset_url('map-icons/flood.png')
        end
      end
      xml.LabelStyle do
        xml.scale "0.7"
      end
    end

    xml << Rails.cache.fetch(cache_key) do
      render 'index_placemarks'
    end
  end
end