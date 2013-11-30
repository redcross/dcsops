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

  def grouped_responder_roles
    @_roles ||= [["Did Not Respond", Incidents::ResponderAssignment::RESPONSES_TO_LABELS.invert.to_a],
     ["Responded To Incident", Incidents::ResponderAssignment::ROLES_TO_LABELS.invert.to_a.reject{|a| a.last == 'team_lead'}]]
  end

  def qualifications(person, abbrevs={})
    person.positions.select{|p|!p.hidden}.map{ |pos|abbrevs[pos.abbrev] = pos.name; "<span data-toggle='tooltip' title='#{h pos.name}'>#{pos.abbrev}</span>".html_safe}.reduce{|a, b| "#{a}, #{b}".html_safe}
  end
end
