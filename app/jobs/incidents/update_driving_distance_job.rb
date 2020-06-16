class Incidents::UpdateDrivingDistanceJob

  def initialize collection=nil
    @collection = collection
  end

  def perform
    real_perform unless Rails.env.test?
  end

  def real_perform
    collection.find_each do |responder_assignment|
      next unless responder_assignment.person.lat && responder_assignment.incident.lat
      distance = Incidents::DirectionsServiceClient.driving_distance responder_assignment.person, responder_assignment.incident
      if distance
        responder_assignment.update_attribute :driving_distance, distance
      end
      sleep 0.5
    end
  end

  def collection
    @collection ||= Incidents::ResponderAssignment.includes(:person, :incident).where(driving_distance: nil).where('updated_at > ?', 3.days.ago)
  end

  class ForIncident
    def initialize incident
      @incident_id = incident
    end

    def incident
      @incident ||= Incidents::Incident.find @incident_id
    end

    def perform
      Incidents::UpdateDrivingDistanceJob.new(incident.all_responder_assignments).perform
    end
  end

end