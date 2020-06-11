class Incidents::Disaster < ApplicationRecord
  has_many :deployments, class_name: 'Incidents::Deployment'

  validates :name, presence: true

  def title
    [dr_number, name].compact.join " "
  end
end
