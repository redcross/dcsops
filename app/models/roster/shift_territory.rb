class Roster::ShiftTerritory < ActiveRecord::Base
  belongs_to :region
  has_many :shift_territory_memberships
  has_many :people, through: :shift_territory_memberships, class_name: 'Roster::Person'

  validates_presence_of :region

  def self.enabled
    where(enabled: true)
  end

  def vc_regex
    @compiled_regex ||= (vc_regex_raw.present? && Regexp.new(vc_regex_raw))
  end

  def display_name
    "#{region.short_name} - #{name}"
  end
end
