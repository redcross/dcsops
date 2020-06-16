class Incidents::Deployment < ApplicationRecord
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :disaster, class_name: 'Incidents::Disaster'

  validates_presence_of :person, :disaster

  scope :for_region, ->(regions) { joins(:person).where(person: { region_id: regions })}
  scope :seen_since, ->(date) { where(date_last_seen: date..DateTime::Infinity.new) }

  def self.for_person person
    where(person_id: person)
  end

  def gap= gap
    super gap
    (self.group, self.activity, self.position, self.qual) = gap.split '/'
  end
end
