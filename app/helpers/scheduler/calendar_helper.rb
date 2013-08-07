module Scheduler::CalendarHelper
  def render_shift_assignment_info(editable, person, shift, my_shift, date, assignments, period)
    s = ""

    if show_county_name
      s << shift.county.abbrev + " "
    end

    s << shift.name + ": "
    if editable and person and (my_shift.nil? or my_shift.shift == shift) and ((can_take_shift?(shift) and shift.can_sign_up_on_day(date, assignments.count)) or (my_shift.try(:shift) == shift and shift.can_remove_on_day(date)))
      cbid = "#{date.to_s}-#{shift.id}"
      s << check_box_tag( shift.id.to_s, date.to_s, my_shift.try(:shift) == shift, class: 'shift-checkbox', :"data-assignment" => my_shift.try(:id), id: cbid, :"data-period" => period)
    end
    s << " "
    if assignments.blank?
      s << label_tag( cbid, 'OPEN')
    elsif assignments.count == 1
      ass = assignments.first
      s << label_tag( cbid, "#{ass.person.first_initial} #{ass.person.last_name}")
    else
      title = assignments.map{|a| a.person.full_name}.join(", ")
      s << content_tag( :span, :"data-toggle" => 'tooltip', title: title, class: 'multiple-assignments') do
        "#{assignments.count} registered"
      end
    end

    s.html_safe
  end

  def view_as_links
    current = params[:display] || ""
    {"Calendar" => "", "Spreadsheet" => 'spreadsheet', 'Grid' => 'grid'}.map do |name, val|
      if val != current
        link_to name, url_for(display: val, counties: show_counties)
      else
        name
      end
    end.join(" | ").html_safe + "<br />".html_safe + link_to( "Download PDF", url_for(format: :pdf, counties: show_counties, show_shifts: params[:show_shifts]))
  end

end


#          -if show_county_name
#            =shift.county.abbrev
#          ="#{shift.name}:"
#          -if editable and person and (my_shift.nil? or my_shift.shift == shift) and (can_take_shift?(shift) and shift.can_sign_up_on_day(date, assignments.count) or my_shift.try(:shift) == shift) and date >= Date.today
#            - cbid = "#{date.to_s}-#{shift.id}"
#            =check_box_tag shift.id.to_s, date.to_s, my_shift.try(:shift) == shift, class: 'shift-checkbox', :"data-assignment" => my_shift.try(:id), id: cbid, :"data-period" => "day"
#
#          -if assignments.blank?
#            %label{for: cbid} OPEN
#          -elsif assignments.count == 1
#            -ass = assignments.first
#            %label{for: cbid}= "#{ass.person.first_initial} #{ass.person.last_name}"
#          -else
#            ="#{assignments.count} registered"#