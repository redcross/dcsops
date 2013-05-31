class Roster::Chapter < ActiveRecord::Base
  has_many :counties
  has_many :positions
  has_many :people

  def time_zone
    @_tz ||= ActiveSupport::TimeZone[self.time_zone_raw]
  end
end
