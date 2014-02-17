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

  def scheduled_responders
    service.scheduled_responders(area: scheduled_area, exclude: exclude_scheduled)
  end

  def flex_responders
    service.flex_responders(area: flex_area, exclude: exclude_flex, limit: self.limit_flex, origin: incident)
  end

  private

  def area
    incident.area
  end

  def set_defaults
    self.ignore_area_flex = true
    self.limit_flex = 15
  end

  def exclude_scheduled
    collection.map(&:person_id)
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