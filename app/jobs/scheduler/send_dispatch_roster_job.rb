class Scheduler::SendDispatchRosterJob
  def self.enqueue *args
    Delayed::Job.enqueue(self.new(*args))
  end

  def initialize(region, force = true, window = 2)
    @force = force
    @trigger_within = window
    @region = region
  end

  attr_reader :force, :trigger_within, :region

  def perform
    Scheduler::ShiftAssignment.transaction do
      if force or shifts_needing_update?
        run!
        Scheduler::ShiftAssignment.for_region(region).joins(:shift).update_all synced: true
      end
    end
  end

  def run!
    Core::JobLog.capture(self.class.to_s, region) do |logger, import_log|
      Core::JobLog.cache do # Enable the query cache here.
        day = region.time_zone.today
        Scheduler::DirectlineMailer.export(region, day - 1, day + 15).deliver
      end
    end
  end

  def shifts_needing_update?
    end_window = Date.current.advance days: trigger_within
    dispatch_shifts = Scheduler::DispatchConfig.for_region(region).active.flat_map(&:shift_list)
    Scheduler::ShiftAssignment.for_region(region).for_shifts(dispatch_shifts).where{(date <= end_window.to_date) & (synced != true)}.exists?
  end
end
