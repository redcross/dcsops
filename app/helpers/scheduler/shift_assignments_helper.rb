module Scheduler::ShiftAssignmentsHelper
  def shift_title(item)
    [current_scopes[:show_shifts]=='all' && item.shift.county.name + " - ", item.shift.name].compact.join
  end

  def shift_summary(item)
    shifts = associated_shifts(item)

    summary = shift_title(item) + "\n\n"
    shifts.each do |(shift, assignments)|
      summary << shift.name + " - "
      if assignments.blank?
        summary << "OPEN"
      else
        summary << assignments.map{|ass| "#{ass.person.full_name} (#{ass.person.primary_phone})"}.join(" ")
      end
      summary << "\n"
    end
    summary
  end
end
