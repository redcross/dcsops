class Incidents::Validators::CompleteReportValidator < DelegatedValidator

  self.target_class = Incidents::DatIncident

  validates :incident_call_type, :structure_type, presence: true

  validates :units_affected, :units_minor, :units_major, :units_destroyed, presence: true, numericality: {:greater_than_or_equal_to => 0, allow_blank: true}
  validates :num_people_injured, :num_people_hospitalized, :num_people_deceased, presence: true, numericality: {:greater_than_or_equal_to => 0, allow_blank: true}

  validates :completed_by, :vehicle_uses, presence: true

  validates_associated :incident

  def validate_first_responders?
    services && services.include?('canteened_responders')
  end
  validates :num_first_responders, presence: {if: :validate_first_responders?}, numericality: {greater_than_or_equal_to: 0, allow_blank: true, if: :validate_first_responders? }

  Incidents::DatIncident::TRACKED_RESOURCE_TYPES.each do |type_s|
    type = type_s.to_sym
    conditional = ->(obj){ obj.incident && obj.incident.chapter.incidents_resources_tracked_array.include?(type_s)}
    validates_presence_of type, if: conditional
    validates_numericality_of type, greater_than_or_equal_to: 0, allow_blank: false, allow_nil: false, if: conditional
  end

end