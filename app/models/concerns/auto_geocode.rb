module AutoGeocode
  extend ActiveSupport::Concern

  included do
    before_save :geocode_address
  end

  def geocode_address
    return if Rails.env.test?
    return if address1 == 'Address' and city == 'City'
    
    if lat.nil? or lng.nil? or (changed & %w(address1 address2 city state zip)).present?
      res = Geokit::Geocoders::GoogleGeocoder3.geocode( [address1, address2, city, state, zip].join(" "))
      if res
        (self.lat, self.lng) = res.lat, res.lng
      else
        self.lat = nil
        self.lng = nil
      end
    end

    return true
  rescue Geokit::TooManyQueriesError
    self.lat = nil
    self.lng = nil

    return true
  end

end