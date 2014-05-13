class Incidents::DirectionsServiceClient
  include HTTParty

  class DirectionsServiceError < StandardError; end

  base_uri "https://maps.googleapis.com/maps/api/directions/"
  format :json

  def self.api_key
    ENV['GOOGLE_API_KEY']
  end

  def self.driving_distance origin, destination
    resp = get '/json', query: { key: api_key, sensor: false, origin: str_from_ll(origin), destination: str_from_ll(destination)}

    status = resp.parsed_response['status']
    if status == 'OK'
      resp.parsed_response['routes'].first['legs'].first['distance']['value'] / 1000 / Geokit::Mappable::KMS_PER_MILE
    elsif status == 'ZERO_RESULTS' || status == 'NOT_FOUND'
      nil
    else
      raise DirectionsServiceError, status
    end
  end

  def self.str_from_ll obj
    "#{obj.lat} #{obj.lng}"
  end

end
