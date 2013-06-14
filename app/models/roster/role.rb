class Roster::Role < ActiveRecord::Base
  serialize :role_scope
  belongs_to :chapter

  validates :name, :grant_name, :chapter, presence: true
end
