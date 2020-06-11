class Incidents::NumberSequence < ApplicationRecord
  has_many :regions, class_name: 'Roster::Region', foreign_key: 'incident_number_sequence_id'

  def next_sequence!
    number = nil
    with_lock do
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
