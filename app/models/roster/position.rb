class Roster::Position < ActiveRecord::Base
  belongs_to :chapter
  has_many :position_memberships

  has_many :role_memberships, class_name: 'Roster::RoleMembership'

  validates_presence_of :chapter, :name

  scope :visible, ->{where{hidden != true}}

  accepts_nested_attributes_for :role_memberships, allow_destroy: true

  def vc_regex
    @compiled_regex ||= (vc_regex_raw.present? && Regexp.new(vc_regex_raw))
  end

  def display_name
    "#{chapter_id} - #{name}"
  end
end
