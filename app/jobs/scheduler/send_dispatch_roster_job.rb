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
        Scheduler::ShiftAssignment.for_chapter(chapter).joins(:shift).update_all synced: true
      end
    end
  end

  def run!
    Core::JobLog.capture(self.class.to_s, chapter) do |logger, import_log|
      Core::JobLog.cache do # Enable the query cache here.
        day = chapter.time_zone.today
        Scheduler::DirectlineMailer.export(chapter, day - 1, day + 15).deliver
      end
    end
  end

  def shifts_needing_update?
    end_window = Date.current.advance days: trigger_within
    dispatch_shifts = Scheduler::DispatchConfig.for_chapter(chapter).active.flat_map(&:shift_list)
    Scheduler::ShiftAssignment.for_chapter(chapter).for_shifts(dispatch_shifts).where('date <= ?', end_window.to_date).where.not(synced: true).exists?
  end
end
