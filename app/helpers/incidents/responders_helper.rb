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

  def person_row(obj, editable = nil)
    person = obj.person
    editable = can?( :create, parent.responder_assignments.build( person: person)) if editable == nil

    content_tag :tr, class: 'person', data: {person: person_json(person, obj, editable), person_id: person.id} do
      safe_join([
        content_tag(:td, role_name(obj)),
        content_tag(:td, qualifications(person)),
        content_tag(:td, link_to(person.full_name, person)),
        content_tag(:td, location(person)),
        tag(:td, class: 'distance'),
        tag(:td, class: 'travel-time'),
        #content_tag(:td) do
        #  link_to 'Send SMS', '', class: 'btn btn-mini' if person.sms_addresses.present? && editable
        #end <<
        content_tag(:td, links(person, obj, editable))
      ])
    end
  end

  def links(person, obj, editable)
    if editable
      link_to('Assign', assignment_url(person, obj), class: 'btn btn-mini', data: {assign: person.id})
    end
  end

  def location(person)
    "#{person.city.try(:titleize)}, #{person.state}" if person.city.present? && person.state.present?
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
    end
  end

  def qualifications(person, abbrevs={})
    quals = person.positions.select{|p|!p.hidden && p.abbrev.present?}
                            .map{ |pos| content_tag(:span, data: {toggle: 'tooltip'}, title: pos.name) { pos.abbrev }}
    safe_join quals, ', '
  end
end
