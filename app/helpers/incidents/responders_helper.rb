module Incidents::RespondersHelper

  def person_json(person, assignment=nil, editable=true)
    assigned = assignment && assignment.is_a?(Incidents::ResponderAssignment)

    Jbuilder.encode do |json|
      json.extract! person, :lat, :lng, :id, :full_name
      json.city person.city.try(:titleize)
      json.assigned assigned

      json.edit_url assignment_url(person, assignment) if editable
      json.role role_name(assignment) if assignment
    end
  end

  def person_editable(person)
     can?( :create, parent.responder_assignments.build( person: person))
  end

  def links(person, obj, editable)
    if editable
      link_to('Assign', assignment_url(person, obj), class: '', data: {assign: person.id})
    end
  end

  def location(person)
    "#{person.city.try(:titleize)}, #{person.state}" if person.city.present? && person.state.present?
  end

  def recruit_action person, editable
    recruitment = recruitments[person.id].try(:first)
    if recruitment
      existing_recruit_status recruitment
    elsif parent.region.incidents_enable_messaging && person.sms_addresses.present? && editable
      recruitment_message_link person
    end
  end

  def recruitment_message_link person
      link_to 'Send Recruitment Message', incidents_region_incident_responder_recruitments_path(parent.region, parent, person_id: person.id), method: :post, remote: true
  end

  def existing_recruit_status recruitment
    if recruitment.unavailable?
      content_tag(:span, "Not Available", class: "text-danger")
    elsif recruitment.available?
      content_tag(:span, "Available", class: "text-success")
    else
      "Message Sent"
    end
  end

  def assignment_url(person, obj)
    if obj && obj.is_a?(Incidents::ResponderAssignment) && obj.persisted?
      edit_resource_path(obj)
    elsif obj.is_a? Scheduler::FlexSchedule
      new_resource_path(person_id: person.id, flex: '1')
    else
      new_resource_path(person_id: person.id)
    end
  end

  def role_name(obj)
    case obj
    when Scheduler::ShiftAssignment then obj.shift.name
    when Incidents::ResponderAssignment then obj.humanized_role
    when String then obj
    end
  end

  def qualifications(person, abbrevs={})
    quals = person.positions.select{|p|!p.hidden && p.abbrev.present?}
                            .map{ |pos| content_tag(:span, data: {toggle: 'tooltip'}, title: pos.name) { pos.abbrev }}
    safe_join quals, ', '
  end

  def format_status_time time
    time.to_s :time
  end

  def assignment_status ass
    if ass.departed_scene_at
      "Departed at #{format_status_time ass.departed_scene_at}"
    elsif ass.on_scene_at
      "On Scene at #{format_status_time ass.on_scene_at}"
    elsif ass.dispatched_at
      "Dispatched at #{format_status_time ass.dispatched_at}"
    else
      "Assigned at #{format_status_time ass.created_at}"
    end
  end

  def status_link ass, label, status
    link_to label, status_resource_path(ass, status: status), method: :post, remote: true, data: {disable_with: "Updating..."}
  end

  def next_status_link ass
    if ass.departed_scene_at

    elsif ass.on_scene_at
      status_link ass, "Mark Departed Scene", 'departed_scene'
    elsif ass.dispatched_at
      status_link ass, "Mark On Scene", 'on_scene'
    else
      status_link ass, "Mark Dispatched", 'dispatched'
    end
  end

  def incoming_messages(incident)
    @incoming ||= Incidents::ResponderMessage.unacknowledged_for_incident(incident).includes(:person).order(:created_at)
  end

  def enable_messaging
    parent.region.incidents_enable_messaging
  end
end
