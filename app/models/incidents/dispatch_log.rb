class Incidents::DispatchLog < ActiveRecord::Base
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :chapter, class_name: 'Roster::Chapter'

  has_many :log_items, class_name: 'Incidents::DispatchLogItem'

  attr_reader :old_changes

  after_save :save_old_changes

  def save_old_changes
    @old_changes = changes
  end
end
