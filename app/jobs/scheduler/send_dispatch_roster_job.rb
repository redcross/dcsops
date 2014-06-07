class Scheduler::SendDispatchRosterJob
  def self.enqueue *args
    Delayed::Job.enqueue(self.new(*args))
  end

  def initialize(chapter, force = true, window = 2)
    @force = force
    @trigger_within = window
    @chapter = chapter
  end

  attr_reader :force, :trigger_within, :chapter

  def perform
    Scheduler::ShiftAssignment.transaction do
      if force or shifts_needing_update?
        run!
        Scheduler::ShiftAssignment.for_chapter(chapter).joins{shift}.update_all synced: true
      end
    end
  end

  def run!
    ImportLog.capture(self.class.to_s, "DirectlineExport") do |logger, import_log|
      ImportLog.cache do # Enable the query cache here.
        day = Date.current
        Scheduler::DirectlineMailer.export(chapter, day - 1, day + 60).deliver
      end
    end
  end

  def shifts_needing_update?
    end_window = Date.current.advance days: trigger_within
    Scheduler::ShiftAssignment.for_chapter(chapter).joins{shift}.where{(shift.dispatch_role != nil) & (date <= end_window.to_date) & (synced != true)}.lock.exists?
  end
end