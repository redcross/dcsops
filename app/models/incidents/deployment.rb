class Incidents::Deployment < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person'

  validates_presence_of :person

  scope :for_chapter, ->(chapter) { joins{person}.where{person.chapter_id == chapter}}
  scope :seen_since, ->(date) { where{date_last_seen >= date} }
end
