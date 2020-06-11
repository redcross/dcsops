class Incidents::CallLog < ApplicationRecord
  belongs_to :region, class_name: "Roster::Region"
  belongs_to :dispatching_region, class_name: "Roster::Region"

  belongs_to :incident, class_name: "Incidents::Incident"
  belongs_to :creator, class_name: "Roster::Person"

  validates :address_entry, :contact_name, :contact_number, :incident_type, presence: {if: :incident?}

  assignable_values_for :call_type do
    %w(incident referral)
  end

  def humanized_valid_incident_types
    i = Incidents::Incident.new
    i.humanized_valid_incident_types
  end

  def incident?
    call_type == "incident"
  end
end
