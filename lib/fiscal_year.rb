# Value class implementing some utility methods around a July-June fiscal year
class FiscalYear
  attr_reader :year

  def self.for_date(date)
    date = date.to_date

    year = date.year
    if date.month >= 7
      year += 1
    end

    self.new(year)
  end

  def self.current
    for_date(Date.current)
  end

  def initialize(year)
    @year = year
  end

  def start_date
    Date.civil(year-1, 7, 1)
  end

  def end_date
    Date.civil(year, 6, 30)
  end

  def range
    start_date..end_date
  end

end