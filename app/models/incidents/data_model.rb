class Incidents::DataModel < ApplicationRecord
  self.abstract_class = true

  has_paper_trail skip: [:cac_number], class_name: 'Version', meta: {
    root_type: ->obj{obj.incident_id && 'Incidents::Incident'}, 
    root_id: ->(obj){obj.incident_id}, 
    region_id: ->(obj){obj.try(:region_id) || obj.incident.try(:region_id)},
  }

  # Some validations cause an infinite loop if the inverses aren't properly set.  Determine whether
  # the association is plural and use it when defining the belongs_to.  CodeClimate whined about this
  # line being duplicated everywhere, but can't imagine this is actually reasonable.
  def self.inherited(c)
    super(c)
    c.class_exec do
      element = self.model_name.element
      inverse = Incidents::Incident.reflect_on_association(element.to_sym) ? element : element.pluralize
      belongs_to :incident, class_name: 'Incidents::Incident', inverse_of: inverse.to_sym
    end
  end
end