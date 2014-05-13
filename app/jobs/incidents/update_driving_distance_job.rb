class Incidents::UpdateDrivingDistanceJob < Struct.new(:collection)

  def perform
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
    @collection || Incidents::ResponderAssignment.includes{[person, incident]}.where{(driving_distance == nil) & (updated_at > 3.days.ago)}
  end
end