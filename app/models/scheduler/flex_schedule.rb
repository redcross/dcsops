class Scheduler::FlexSchedule < ActiveRecord::Base
  belongs_to :person, foreign_key: 'id', class_name: 'Roster::Person'

  scope :for_county, lambda {|county_ids| 
    joins{person.county_memberships}.where{person.county_memberships.county_id.in my{county_ids}}
  }

  def available(day, shift)
    self.send "available_#{day}_#{shift}".to_sym
  end

  def num_shifts
    shifts = 0
    %w(sunday monday tuesday wednesday thursday friday saturday).each do |day|
      %w(day night).each do |shift|
        shifts = shifts+1 if available(day, shift)
      end
    end
    shifts
  end
end
