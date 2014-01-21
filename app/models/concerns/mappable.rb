module Mappable
  extend ActiveSupport::Concern

  include Geokit::Mappable

  included do
    class_attribute :lat_column_name, :lng_column_name
    self.lat_column_name = :lat
    self.lng_column_name = :lng
  end
end