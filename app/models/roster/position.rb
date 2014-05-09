class Roster::Position < ActiveRecord::Base
  belongs_to :chapter
  has_many :position_memberships

  has_and_belongs_to_many :roles, class_name: 'Roster::Role'

  validates_presence_of :chapter, :name

  serialize :role_scope

  scope :visible, ->{where{hidden != true}}

  def vc_regex
    @compiled_regex ||= (vc_regex_raw.present? && Regexp.new(vc_regex_raw))
  end

  def display_name
    "#{chapter_id} - #{name}"
  end
end
