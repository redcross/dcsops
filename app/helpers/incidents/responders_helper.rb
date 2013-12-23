module Incidents::RespondersHelper
  def scheduled_people_json
    Jbuilder.encode do |json|
      json.array!(scheduled_responders) do |ass|
        person = ass.person
        json.extract! person, :lat, :lng, :id, :full_name
        json.city person.city.titleize

        if assignment
          json.role assignment.shift.name
        end
      end
    end
  end

  def person_json(person, assignment=nil)
    Jbuilder.encode do |json|
      json.extract! person, :lat, :lng, :id, :full_name
      json.city person.city.try(:titleize)

      if assignment
        json.role assignment.shift.name
      end
    end
  end

  def person_row(obj)
    person = obj.person
    editable = can?( :create, parent.responder_assignments.build( person: person))
    content_tag :tr, class: 'person', data: {person: person_json(person), person_id: person.id} do
      content_tag(:td) do
        case obj
        when Scheduler::ShiftAssignment then obj.shift.name
        when Incidents::ResponderAssignment then obj.humanized_role
        end
      end <<
      content_tag( :td, qualifications(person)) <<
      content_tag(:td, link_to(person.full_name, person)) <<
      content_tag(:td) do
        "#{person.city.try(:titleize)}, #{person.state}" if person.city.present? && person.state.present?
      end <<
      tag(:td, class: 'distance') <<
      tag(:td, class: 'travel-time') <<
      #content_tag(:td) do
      #  link_to 'Send SMS', '', class: 'btn btn-mini' if person.sms_addresses.present? && editable
      #end <<
      content_tag(:td) do
        if editable
          if obj.is_a?(Incidents::ResponderAssignment) && obj.persisted?
            path = edit_resource_path(obj)
          else
            path = new_resource_path(person_id: person.id)
          end
          link_to( 'Assign', path, class: 'btn btn-mini', data: {assign: person.id})
        end
      end
    end
  end


  def grouped_responder_roles
    @_roles ||= [["Did Not Respond", Incidents::ResponderAssignment::RESPONSES_TO_LABELS.invert.to_a],
     ["Responded To Incident", Incidents::ResponderAssignment::ROLES_TO_LABELS.invert.to_a.reject{|a| a.last == 'team_lead'}]]
  end

  def qualifications(person, abbrevs={})
    person.positions.select{|p|!p.hidden}.map{ |pos|abbrevs[pos.abbrev] = pos.name; "<span data-toggle='tooltip' title='#{h pos.name}'>#{pos.abbrev}</span>".html_safe}.reduce{|a, b| "#{a}, #{b}".html_safe}
  end
end
