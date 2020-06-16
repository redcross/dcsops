class MOTD < ApplicationRecord
  belongs_to :region, class_name: 'Roster::Region'

  scope :with_region_or_none, -> (region) { where(region: region).or(where(region: nil)) }
  scope :beginning_before, -> (now) { where(begins: nil).or(where('begins <= ?', now)) }
  scope :ending_after,     -> (now) { where(ends: nil).or(where('ends >= ?', now)) }
  scope :active, -> (region) do
    now = region.time_zone.now
    with_region_or_none(region).beginning_before(now).ending_after(now)
  end

  def path_regex
    @compiled_regex ||= (path_regex_raw && Regexp.new(path_regex_raw))
  end
end
