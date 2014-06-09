class Scheduler::SubmitHoursJob
  def enqueue_all

  end

  def initialize(chapter_id)
    @chapter_id = chapter_id
  end

  def chapter
    @chapter ||= Roster::Chapter.find @chapter_id
  end

  def client
    @client ||= Vc::Client.new chapter.vc_username, chapter.vc_password
  end

  def assignments_to_upload
    Scheduler::ShiftAssignment.joins{shift}.includes{[person, shift_group, shift]}.readonly(false).where{(shift.vc_hours_type != nil) & (vc_hours_uploaded != true)}
  end

  def perform
    to_upload = assignments_to_upload.group_by(&:person)
    to_upload.each do |person, assignments|
      time = assignments.map{|a| hours = (a.shift_group.end_offset - a.shift_group.start_offset) / 1.hour; (hours*4).round / 4}.sum
      desc = assignments.map{|a| "#{shift_group.name} #{shift.name} on #{a.date}"}.join("\n")
      client.hours.submit_hours person.vc_id, desc, time
      assignments.each{|a| a.update_attribute :vc_hours_uploaded, true}
    end
  end
end