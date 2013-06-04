class Roster::Position < ActiveRecord::Base
  belongs_to :chapter
  has_many :position_memberships

  validates_presence_of :chapter

  serialize :role_scope

  scope :visible, ->{where{hidden != true}}

  def vc_regex
    @compiled_regex ||= (vc_regex_raw && Regexp.new(vc_regex_raw))
  end
end
