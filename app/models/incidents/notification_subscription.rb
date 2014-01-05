class Incidents::NotificationSubscription < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :county, class_name: 'Roster::County'

  TYPES = %w(new_incident incident_dispatch incident_report missing_report weekly)

  validates :notification_type, inclusion: {in: TYPES}, presence: true, uniqueness: {scope: [:person_id, :county_id]}

  scope :for_chapter, -> (chapter) {
    joins{person}.where{person.chapter_id == chapter}
  }

  scope :for_county, ->(county) {
    where{(county_id == nil) | (county_id == county)}
  }

  scope :for_type, ->(type) {
    where{notification_type == type}
  }
end