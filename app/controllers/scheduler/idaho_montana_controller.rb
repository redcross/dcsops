class Scheduler::IdahoMontanaController < Scheduler::BaseController
  layout false
  inherit_resources
  helper_method :current_time
  skip_before_action :require_valid_user!, :only => :idaho_montana

  def collection
    @collection ||= todays_assignments
  end

  def current_time
    idaho_montana.time_zone.now
  end

  private

  def idaho_montana
    @idaho_montana ||= Roster::Region.find_by_url_slug("idaho_montana")
  end

  def todays_assignments
    shift_names = [
      ['Region', 'Duty Officer'],
      ['Region', 'Regional Leadership On Call'],
    ]

    shift_times = Scheduler::ShiftTime.current_groups_for_region(idaho_montana)
    shift_names.map {|shift_territory_name, shift_name|
      s_t = Roster::ShiftTerritory.where(name: shift_territory_name, region: idaho_montana).first
      s = Scheduler::Shift.where(name: shift_name, shift_territory: s_t).active_on_day(Date.today).first
      s_a = shift_times.map {|shift_time|
        Scheduler::ShiftAssignment.where(shift_time: shift_time, shift: s, date: shift_time.start_date).to_a
      }.flatten.first
      [s, s_a]
    }
  end
end
