class Incidents::DispatchLog < ApplicationRecord
  belongs_to :incident, class_name: 'Incidents::Incident'
  belongs_to :region, class_name: 'Roster::Region'

  has_many :log_items, class_name: 'Incidents::DispatchLogItem'

  attr_reader :old_changes

  after_save :save_old_changes

  def save_old_changes
    @old_changes = changes
  end

  def num_dials
    log_items.to_a.count{|li| li.action_type == 'Dial'}
  end
end
