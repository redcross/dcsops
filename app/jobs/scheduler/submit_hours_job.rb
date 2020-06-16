class Scheduler::SubmitHoursJob
  def self.enqueue_all
    Roster::Region.with_scheduler_submit_vc_hours_value(true).ids.each do |region_id|
      new(region_id).perform
    end
  end

  def initialize(region_id, assignment_ids=nil)
    @region_id = region_id
    @assignment_ids = assignment_ids
  end

  def perform
    Core::JobLog.capture self.class.to_s, region do |log, counter|
      @counter = counter
      upload_hours
    end
  end

  protected

  def region
    @region ||= Roster::Region.find @region_id
  end

  def client
    @client ||= Vc::Client.new region.vc_username, region.vc_password
  end

  def assignments_to_upload
    if @assignment_ids
      Scheduler::ShiftAssignment.where(id: @assignment_ids)
    else
      Scheduler::ShiftAssignment.joins(:shift).includes(:person, :shift_time, :shift).for_region(region).readonly(false)
        .where.not(shift: { vc_hours_type: nil })
        .where.not(vc_hours_uploaded: true)
        .where('date < ?', region.time_zone.today)
    end
  end

  def count
    @counter.row!
  end

  def upload_hours
    to_upload = assignments_to_upload.group_by(&:person)
    to_upload.each do |person, assignments|
      assignments.group_by{|a| a.shift.vc_hours_type}.each do |type, assignments|
        time = assignments.map{|a| hours = (a.shift_time.end_offset - a.shift_time.start_offset) / 1.hour; (hours*4).round / 4}.sum
        desc = assignments.map{|a| "#{a.shift_time.name} #{a.shift.name} on #{a.date.to_s :mdy}"}.join("\n")
        client.hours.submit_hours person.vc_id, desc, time, hours_type: type
        count
      end
      assignments.each{|a| a.update_attribute :vc_hours_uploaded, true}
    end
  end
end