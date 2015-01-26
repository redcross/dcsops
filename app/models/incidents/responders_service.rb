class Incidents::RespondersService
  attr_reader :incident, :collection, :service
  attr_accessor :ignore_area_scheduled
  attr_accessor :ignore_area_flex, :limit_flex
  attr_accessor :ignore_dispatch

  def initialize(incident, collection, options={})
    @incident = incident
    @collection = collection
    set_defaults

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
    @scheduled ||= service.scheduled_responders(areas: scheduled_areas, exclude: exclude_scheduled, dispatch_console: true).preload{person.positions}
  end

  def flex_responders
    @flex ||= service.flex_responders(areas: flex_areas, exclude: exclude_flex, limit: self.limit_flex, origin: incident)
  end

  private

  def dispatch_responders
    @dispatch ||= (incident.territory && service.dispatch_assignments(territory: territory))
  end

  def territory
    incident.territory
  end

  def areas
    territory.calendar_counties
  end

  def set_defaults
    self.ignore_area_flex = incident.chapter.incidents_dispatch_console_ignore_county
    self.limit_flex = 15
  end

  def collection_people
    @people ||= collection.map(&:person_id)
  end

  def exclude_scheduled
    collection_people + (ignore_dispatch ? [] : dispatch_shifts.map(&:person_id))
  end

  def scheduled_areas
    ignore_area_scheduled ? nil : areas
  end

  def flex_areas
    ignore_area_flex ? nil : areas
  end

  def exclude_flex
    service.scheduled_responders(areas: flex_areas).map(&:person_id) + exclude_scheduled
  end

end
