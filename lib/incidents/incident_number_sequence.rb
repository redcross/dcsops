class Incidents::IncidentNumberSequence
  attr_reader :chapter

  def initialize(chapter)
    @chapter = chapter
  end

  def next_sequence!
    number = nil
    chapter.with_lock do
      check_year
      number = (chapter.incidents_sequence_number += 1)
      chapter.save!
    end

    format = chapter.incidents_sequence_format
    fy_short = chapter.incidents_sequence_year % 100
    sprintf(format, {fy: chapter.incidents_sequence_year, fy_short: fy_short, number: number})
  end

  def check_year
    current_fy = chapter.incidents_sequence_year
    fiscal = FiscalYear.current

    if fiscal.year > current_fy
      chapter.incidents_sequence_year = fiscal.year
      chapter.incidents_sequence_number = 0
    end
  end
end
