class Incidents::RespondersService
  attr_reader :incident, :collection, :service
  attr_accessor :ignore_area_scheduled
  attr_accessor :ignore_area_flex, :limit_flex

  def initialize(incident, collection, options={})
    set_defaults
    @incident = incident
    @collection = collection

    @service = Scheduler::SchedulerService.new(incident.chapter)

    options.each do |name, val|
      self.send "#{name}=", val
    end
  end

  def dispatch_shifts
    @dispatch_shifts ||= have_dispatch? ? dispatch_responders[:assignments].reject{|a| collection_people.include? a.person_id} : []
  end

  def dispatch_backup
    @dispatch_backup ||= have_dispatch? ? dispatch_responders[:backup].reject{|p| collection_people.include?(p.id) || dispatch_shifts.detect{|sh| sh.person_id == p.id } } : []
  end

  def have_dispatch?
    dispatch_responders && dispatch_responders[:present]
  end

  def scheduled_responders
    service.scheduled_responders(area: scheduled_area, exclude: exclude_scheduled)
  end

  def flex_responders
    service.flex_responders(area: flex_area, exclude: exclude_flex, limit: self.limit_flex, origin: incident)
  end

  private

  def dispatch_responders
    @dispatch ||= (incident.area && service.dispatch_assignments(area: incident.area))
  end

  def area
    incident.area
  end

  def set_defaults
    self.ignore_area_flex = true
    self.limit_flex = 15
  end

  def collection_people
    @people ||= collection.map(&:person_id)
  end

  def exclude_scheduled
    collection_people + dispatch_shifts.map(&:person_id)
  end

  def scheduled_area
    ignore_area_scheduled ? nil : area
  end

  def flex_area
    ignore_area_flex ? nil : area
  end

  def exclude_flex
    service.scheduled_responders(area: flex_area).map(&:person_id) + exclude_scheduled
  end

end
