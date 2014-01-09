class Incidents::NotificationSubscription < ActiveRecord::Base
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :county, class_name: 'Roster::County'

  validates :notification_type, uniqueness: {scope: [:person_id, :county_id]}
  validates :frequency, presence: {if: ->(sub) {sub.notification_type == 'report'}}
  validates :person, presence: true

  assignable_values_for :notification_type do
    %w(new_incident incident_dispatch incident_report missing_report report)
  end

  FREQUENCIES = %w(daily weekly weekdays)

  assignable_values_for :frequency, allow_blank: true do
    (person.try(:chapter).try(:incidents_enabled_report_frequencies_array) || []) & FREQUENCIES
  end

  before_validation :set_frequency, on: :create
  def set_frequency
    self.frequency ||= self.assignable_frequencies.first if self.notification_type == 'report'
  end

  scope :for_chapter, -> (chapter) {
    joins{person}.where{person.chapter_id == chapter}
  }

  scope :for_county, ->(county) {
    where{(county_id == nil) | (county_id == county)}
  }

  scope :for_type, ->(type) {
    where{notification_type == type}
  }

  scope :to_send_on, ->(today) {
    where <<-SQL, {today: today}
    (CASE frequency
    WHEN 'daily' THEN :today::date
    WHEN 'weekly' THEN date_trunc('week', :today::timestamp)::date
    WHEN 'weekdays' THEN
      CASE 
      WHEN EXTRACT(dow FROM :today::date) IN (1, 2, 3, 4, 5) THEN :today::date
      WHEN EXTRACT(dow FROM :today::date) = 6 THEN :today::date - INTERVAL '1 day'
      WHEN EXTRACT(dow FROM :today::date) = 0 THEN :today::date - INTERVAL '2 days'
      END
    END) > last_sent OR last_sent IS NULL
    SQL
  }

  scope :with_active_person, ->{
    joins{person}.where{person.vc_is_active == true}
  }

  def time_zone
    person.chapter.time_zone
  end

  def range_to_send
    raise ArgumentError, 'Must specify a frequency' unless frequency and person
    today = time_zone.today
    yesterday = today.yesterday
    case frequency
    when 'weekly'
      bow = today.at_beginning_of_week
      (bow-7)..(bow-1)
    when 'weekday'
      if today.wday == 1
        (yesterday-2)..(yesterday)
      else
        yesterday..yesterday
      end
    else
      yesterday..yesterday
    end
  end
end