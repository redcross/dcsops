class Roster::County < ActiveRecord::Base
  belongs_to :region
  has_many :county_memberships
  has_many :people, through: :county_memberships, class_name: 'Roster::Person'

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
