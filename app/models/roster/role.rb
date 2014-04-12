class Roster::Role < ActiveRecord::Base
  belongs_to :chapter

  validates :name, :grant_name, :chapter, presence: true
  has_many :role_scopes

  accepts_nested_attributes_for :role_scopes, allow_destroy: true

  def display_name
    "#{chapter_id} - #{name}"
  end
end
