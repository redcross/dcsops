class MOTD < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'

  scope :active, ->(region){now = region.time_zone.now; where{((region_id == region) | (region_id == nil)) & ((begins == nil) | (begins <= now)) & ((ends == nil) | (ends >= now))}}

  def path_regex
    @compiled_regex ||= (path_regex_raw && Regexp.new(path_regex_raw))
  end
end
