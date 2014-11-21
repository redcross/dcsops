class Incidents::DispatchService
  def initialize(incident)
    @incident = incident
  end

  attr_reader :incident

  def assign_contact
    service = Incidents::RespondersService.new(incident, incident.responder_assignments)
    shift = service.dispatch_shifts.first
    if shift
      person = shift.person
    else
      person = service.dispatch_backup.first
    end

    incident.update current_dispatch_contact_id: person.try(:id)
  end
end