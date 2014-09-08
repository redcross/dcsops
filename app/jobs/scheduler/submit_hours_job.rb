class Scheduler::SubmitHoursJob
  def enqueue_all
    Roster::Chapter.with_scheduler_submit_vc_hours_value(true).ids.each do |chapter|
      new(chapter.id).perform
    end
  end

  def initialize(chapter_id, assignment_ids=nil)
    @chapter_id = chapter_id
    @assignment_ids = assignment_ids
  end

  def perform
    Core::JobLog.capture self.class.to_s, chapter do |log, counter|
      @counter = counter
      upload_hours
    end
  end

  protected

  def chapter
    @chapter ||= Roster::Chapter.find @chapter_id
  end

  def client
    @client ||= Vc::Client.new chapter.vc_username, chapter.vc_password
  end

  def assignments_to_upload
    if @assignment_ids
      Scheduler::ShiftAssignment.where{id.in my{@assignment_ids}}
    else
      Scheduler::ShiftAssignment.joins{shift}.includes{[person, shift_group, shift]}.for_chapter(chapter).readonly(false).where{(shift.vc_hours_type != nil) & (vc_hours_uploaded != true) & (date < my{chapter.time_zone.today})}
    end
  end

  def count
    @counter.row!
  end

  def upload_hours
    to_upload = assignments_to_upload.group_by(&:person)
    to_upload.each do |person, assignments|
      assignments.group_by{|a| a.shift.vc_hours_type}.each do |type, assignments|
        time = assignments.map{|a| hours = (a.shift_group.end_offset - a.shift_group.start_offset) / 1.hour; (hours*4).round / 4}.sum
        desc = assignments.map{|a| "#{a.shift_group.name} #{a.shift.name} on #{a.date.to_s :mdy}"}.join("\n")
        client.hours.submit_hours person.vc_id, desc, time, hours_type: type
        count
      end
      assignments.each{|a| a.update_attribute :vc_hours_uploaded, true}
    end
  end
end