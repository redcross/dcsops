class Roster::County < ActiveRecord::Base
  belongs_to :chapter
  has_many :county_memberships

  has_many :counties
  has_many :positions

  def vc_regex
    @compiled_regex ||= (vc_regex_raw && Regexp.new(vc_regex_raw))
  end
end
