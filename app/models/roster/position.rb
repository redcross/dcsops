class Roster::Position < ActiveRecord::Base
  belongs_to :chapter
  has_many :position_memberships

  has_and_belongs_to_many :roles, class_name: 'Roster::Role'

  validates_presence_of :chapter

  serialize :role_scope

  scope :visible, ->{where{hidden != true}}

  def vc_regex
    @compiled_regex ||= (vc_regex_raw.present? && Regexp.new(vc_regex_raw))
  end
end
