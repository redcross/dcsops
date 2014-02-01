class Incidents::DispatchLogItem < ActiveRecord::Base
  belongs_to :dispatch_log

  def description
    "#{action_type}: #{recipient}\nResult: #{result}"
  end
end
