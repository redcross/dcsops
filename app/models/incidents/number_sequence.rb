class Incidents::NumberSequence < ApplicationRecord
  has_many :regions, class_name: 'Roster::Region', foreign_key: 'incident_number_sequence_id'

  @@mutex = Mutex.new

  def next_sequence!
    number = nil

    # This code used to use "with_lock" but with the rails upgrade, that started
    # failing, saying that we couldn't lock on a resource that wasn't saved.  So
    # instead of locking on the database, we'll just lock on an object in memory.
    #
    # However, I'm not super positive that this will actually prevent the race
    # condition in production, since I don't have a full grasp of how rails creates
    # objects and classes, and I think the class level mutex will work.
    @@mutex.synchronize do
      check_year
      number = (self.current_number += 1)
      save!
    end

    fy_short = current_year % 100
    sprintf(format, {fy: current_year, fy_short: fy_short, number: number})
  end

  def check_year
    current_fy = current_year
    fiscal = FiscalYear.current

    if fiscal.year > current_fy
      self.current_year = fiscal.year
      self.current_number = 0
    end
  end
end
