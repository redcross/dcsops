class Incidents::ReportSubscription < ApplicationRecord
  belongs_to :person, class_name: 'Roster::Person'
  belongs_to :shift_territory, class_name: 'Roster::ShiftTerritory'
  belongs_to :scope, class_name: 'Incidents::Scope'

  validates :report_type, uniqueness: {scope: [:person_id, :scope_id]}
  validates :person, :scope, :frequency, presence: true

  #assignable_values_for :report_type do
  #  %w(report)
  #end
#
  FREQUENCIES = %w(daily weekly weekdays)

  assignable_values_for :frequency, allow_blank: true do
    scope && scope.report_frequencies_array(FREQUENCIES) || []
  end

  before_validation :set_frequency, on: :create
  def set_frequency
    self.frequency ||= self.assignable_frequencies.first# if self.report_type == 'report'
  end

  def self.for_scope scope
    where{scope_id == scope}
  end

  #def self.for_region region
  #  joins{person}.where{person.region_id == region}
  #end
#
  #def self.for_shift_territory shift_territory
  #  where{(shift_territory_id == nil) | (shift_territory_id == shift_territory)}
  #end

  def self.for_type type
    where{report_type == type}
  end

  def self.to_send_on today
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
  end

  def self.with_active_person
    joins{person}.where{person.vc_is_active == true}
  end

  def time_zone
    person.region.time_zone
  end

  def range_to_send
    raise ArgumentError, 'Must specify a frequency' unless frequency and person
    today = time_zone.today
    yesterday = today.yesterday
    case frequency
    when 'weekly'
      bow = today.at_beginning_of_week
      (bow-7)..(bow-1)
    when 'weekdays'
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