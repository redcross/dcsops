module Scheduler::ShiftAssignmentsHelper
  def shift_title(item)
    title = ""
    if current_scopes[:show_shifts]=='all'
      title << item.shift.county.name << " - "
    end
    title << item.shift.name
    title
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
