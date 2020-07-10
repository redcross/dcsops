module Scheduler::CalendarHelper

  # Calls its block once for each shift, with helpful rendering info computed
  def render_shifts group, shifts, date, editable
    # Block expects: idx, is_first, is_last, needs_signups, row_html
    my_shifts = person ? calendar.my_shifts_for_group_on_day(group.id, date) : []
    today = current_region.time_zone.today

    shifts.sort_by(&:ordinal).each_with_index do |shift, idx|
      assignments=calendar.assignments_for_shift_on_day_in_group(shift, date, group)
      row_html = render_shift_assignment_info(editable, person, shift, group, my_shifts, date, assignments, group_to_period(group))
      is_first = (idx == 0)
      is_last = (idx == (shifts.size-1))
      needs_signups = assignments.size < shift.min_desired_signups && date >= today
      yield idx, is_first, is_last, needs_signups, row_html
    end
  end

  def group_to_period group
    case group.period
    when 'daily' then 'day'
    when 'weekly' then 'week'
    when 'monthly' then 'monthly'
    end
  end

  # Helper to cache the result of the shift method, since there may be
  # 900+ shift lines rendered, only for one person, and maybe 10 shifts
  def can_be_taken_by? shift, person
    @taken_cache ||= Hash.new{|h, k| h[k] = k.first.can_be_taken_by?(k.last) }
    @taken_cache[[shift, person]]
  end

  def today
    @today ||= current_region.time_zone.today
  end



  # Renders one line of shift info for the calendar
  # Editable: must be true to enable the checkbox
  # Person: Person we're editing
  # Shift: Shift to display
  # my_shift: The shift assignment for the given person on the given day (if it exists) - not necessarily for the shift we're rendering
  # date: Date for this shift instance
  # assignments: Any shift assignments for the given shift on the given date (may include my_shift if appropriate)
  # period: day/week/month, so the javascript knows what to reload if the shift is edited
  def render_shift_assignment_info(editable, person, shift, shift_time, my_shifts, date, assignments, period)
    can_take = person && can_be_taken_by?(shift, person)
    can_sign_up = shift.can_sign_up_on_day(date, shift_time, assignments.count, today)
    can_remove = shift.can_remove_on_day(date, shift_time, today)
    this_assignment = my_shifts && my_shifts.detect{|sa| sa.shift == shift && sa.shift_time == shift_time}
    is_signed_up = this_assignment.present?

    cbid = "#{date.to_s}-#{shift.id}-#{shift_time.id}"

    my_shifts_exclusive = my_shifts.present? && my_shifts.any?{|sa| sa.shift.exclusive }
    can_take_exclusive = editable && (this_assignment.present? || !shift.exclusive || !my_shifts_exclusive)

    #pp shift_time, my_shifts
    #puts "Editable: #{editable}; Can take #{can_take}; can_sign_up: #{can_sign_up}, can_remove: #{can_remove}, is_signed_up: #{is_signed_up}, my_shifts_exclusive: #{my_shifts_exclusive}, can_take_exclusive: #{can_take_exclusive}"

    s = ActiveSupport::SafeBuffer.new

    if show_shift_territory?
      s << shift.shift_territory.abbrev << " "
    end

    s << shift.name << ": "
    if can_take_exclusive and person and ((can_take and can_sign_up) or (is_signed_up and can_remove))
      s << check_box_tag(shift.id.to_s, # Name
                         date.to_s,     # Value
                         is_signed_up,  # Checked?
                         id: cbid, 
                         class: 'shift-checkbox',
                          data: {
                            :assignment => this_assignment.try(:id), 
                            :period => period,
                            params: create_params(person, shift, shift_time, date)
                          }) << " "

    end
    s << render_assignments_label(assignments, cbid)

    s
  end

  def create_params person, shift, shift_time, date
    JSON.generate({person_id: person.id, shift_id: shift.id, shift_time_id: shift_time.id, date: date})
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

    link_params = {action: :show, year: date.year, month: date.strftime("%B").downcase, display: current}.merge ajax_params

    links = {"Calendar" => "", "Printable" => 'spreadsheet'}.map do |name, val|
      if val != current
        link_to name, url_for(link_params.merge({display: val}))
      else
        name
      end
    end

    safe_join(links, " | ") + tag(:br) + link_to( "Download PDF", url_for(link_params.merge format: :pdf))
  end

  def ajax_params
    {
      person_id: person.try(:id),
      show_shifts: show_shifts,
      shift_territories: show_shift_territories,
      categories: show_categories
    }
  end

  def show_shift_territory?
    calendar.all_groups.flat_map{|_, shifts| shifts.map(&:shift_territory_id)}.uniq.count > 1
  end

  # Possibly unused
  def show_only_available
    params[:only_available] == 'true'
  end
end
