module AutoGeocode
  extend ActiveSupport::Concern

  mattr_accessor :enabled_in_test
  self.enabled_in_test = false
  mattr_accessor :enabled
  self.enabled = true

  mattr_accessor :geocodes
  mattr_accessor :failed
  self.geocodes = 0
  self.failed = 0

  def self.enabled?
    self.enabled && (!Rails.env.test? || AutoGeocode.enabled_in_test)
  end

  def self.count!(fail)
    self.geocodes += 1
    self.failed += 1 if fail
  end

  included do
    before_save :geocode_address

    class_attribute :geocode_columns
    self.geocode_columns = %w(address1 address2 city state zip)
  end

  def geocode_address(force=false)
    return unless AutoGeocode.enabled?

    cols = self.class.geocode_columns
    return if cols.any?{|c| %w(Address City).include? self[c] }
    
    if force or lat.nil? or lng.nil? or (changed & cols).present?
      address = cols.map{|c| self[c] }.compact.join " "
      if address.present?
        Rails.logger.info "Geocoding: #{address}"
        res = Geokit::Geocoders::GoogleGeocoder.geocode(address)
        if res
          (self.lat, self.lng) = res.lat, res.lng
        else
          self.lat = nil
          self.lng = nil
        end

        AutoGeocode.count! false
      end
    end

    return true
  rescue Geokit::Geocoders::TooManyQueriesError
    self.lat = nil
    self.lng = nil

    AutoGeocode.count! true

    return true
  end

end