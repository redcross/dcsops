module Scheduler::CalendarHelper
  # Renders one line of shift info for the calendar
  # Editable: must be true to enable the checkbox
  # Person: Person we're editing
  # Shift: Shift to display
  # my_shift: The shift assignment for the given person on the given day (if it exists) - not necessarily for the shift we're rendering
  # date: Date for this shift instance
  # assignments: Any shift assignments for the given shift on the given date (may include my_shift if appropriate)
  # period: day/week/month, so the javascript knows what to reload if the shift is edited
  def render_shift_assignment_info(editable, person, shift, my_shift, date, assignments, period)
    can_take = person && shift.can_be_taken_by?(person)
    can_sign_up = shift.can_sign_up_on_day(date, assignments.count)
    can_remove = shift.can_remove_on_day(date)
    is_signed_up = my_shift.try(:shift) == shift
    cbid = "#{date.to_s}-#{shift.id}"

    s = ActiveSupport::SafeBuffer.new

    if show_county_name?
      s << shift.county.abbrev << " "
    end

    s << shift.name + ": "
    if editable and person and (my_shift.nil? or is_signed_up) and ((can_take and can_sign_up) or (is_signed_up and can_remove))
      s << check_box_tag( shift.id.to_s, date.to_s, is_signed_up, class: 'shift-checkbox', :"data-assignment" => my_shift.try(:id), id: cbid, :"data-period" => period) << " "
    end
    s << render_assignments_label(assignments, cbid)

    s
  end

  def render_assignments_label(assignments, cbid)
    if assignments.blank?
      label_tag( cbid, 'OPEN')
    elsif assignments.count == 1
      ass = assignments.first
      label_tag(cbid, "#{ass.person.first_initial} #{ass.person.last_name}")
    else
      title = assignments.map{|a| a.person.full_name}.join(", ")
      content_tag(:span, :"data-toggle" => 'tooltip', title: title, class: 'multiple-assignments') do
        "#{assignments.count} registered"
      end
    end
  end

  def view_as_links
    current = params[:display] || ""
    links = {"Calendar" => "", "Spreadsheet" => 'spreadsheet', 'Grid' => 'grid'}.map do |name, val|
      if val != current
        link_to name, url_for(display: val, counties: show_counties)
      else
        name
      end
    end

    safe_join(links, " | ") + tag(:br) + link_to( "Download PDF", url_for(format: :pdf, counties: show_counties, show_shifts: params[:show_shifts]))
  end

  def ajax_params
    {
      person_id: person.try(:id),
      show_shifts: show_shifts,
      counties: show_counties
    }
  end

  def show_county_name?
    calendar.all_groups.flat_map{|_, shifts| shifts.map(&:county_id)}.uniq.count > 1
  end

  # Possibly unused
  def show_only_available
    params[:only_available] == 'true'
  end
end
