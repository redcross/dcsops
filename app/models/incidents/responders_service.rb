class Incidents::RespondersService
  attr_reader :incident, :collection, :service
  attr_accessor :ignore_shift_territory_scheduled
  attr_accessor :ignore_shift_territory_flex, :limit_flex
  attr_accessor :ignore_dispatch

  def initialize(incident, collection, options={})
    @incident = incident
    @collection = collection
    set_defaults

    @service = Scheduler::SchedulerService.new(incident.region)

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
    @scheduled ||= service.scheduled_responders(shift_territories: scheduled_shift_territories, exclude: exclude_scheduled, dispatch_console: true).preload(person: :positions)
  end

  def flex_responders
    @flex ||= service.flex_responders(shift_territories: flex_shift_territories, exclude: exclude_flex, limit: self.limit_flex, origin: incident)
  end

  private

  def dispatch_responders
    @dispatch ||= (incident.response_territory && service.dispatch_assignments(response_territory: response_territory))
  end

  def response_territory
    incident.response_territory
  end

  def shift_territories
    response_territory.shift_territories
  end

  def set_defaults
    self.ignore_shift_territory_flex = incident.region.incidents_dispatch_console_ignore_shift_territory
    self.limit_flex = 100
  end

  def collection_people
    @people ||= collection.map(&:person_id)
  end

  def exclude_scheduled
    collection_people + (ignore_dispatch ? [] : dispatch_shifts.map(&:person_id))
  end

  def scheduled_shift_territories
    ignore_shift_territory_scheduled ? nil : shift_territories
  end

  def flex_shift_territories
    ignore_shift_territory_flex ? nil : shift_territories
  end

  def exclude_flex
    service.scheduled_responders(shift_territories: flex_shift_territories).map(&:person_id) + exclude_scheduled
  end

end
