class Roster::County < ApplicationRecord
  belongs_to :chapter
  has_many :county_memberships
  has_many :people, through: :county_memberships, class_name: 'Roster::Person'

  validates_presence_of :chapter

  def self.enabled
    where(enabled: true)
  end

  def vc_regex
    @compiled_regex ||= (vc_regex_raw.present? && Regexp.new(vc_regex_raw))
  end

  def display_name
    "#{chapter.short_name} - #{name}"
  end
end
