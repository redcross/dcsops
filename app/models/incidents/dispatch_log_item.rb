class Incidents::DispatchLogItem < ApplicationRecord
  belongs_to :dispatch_log

  def self.not_sms_internal
    where('action_type NOT LIKE ?', 'SMS Message %')
  end

  def description
    "#{action_type}: #{recipient}\nResult: #{result}"
  end
end
