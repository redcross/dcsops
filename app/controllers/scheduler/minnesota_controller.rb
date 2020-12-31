class Scheduler::MinnesotaController < Scheduler::BaseController
  layout false
  inherit_resources
  helper_method :current_time
  skip_before_filter :require_valid_user!, :only => :minnesota

  def collection
    @collection ||= todays_assignments
  end

  def current_time
    mn.time_zone.now
  end

  private

  def mn
    @mn ||= Roster::Region.find_by_url_slug("minn_dak")
  end

  def todays_assignments
    shift_names = [
      ['Twin Cities Area', ['Duty Officer - Twin Cities Area', 'Duty Officer - Back-up - Twin Cities Area']],
      ['Central North Minnesota', ['Duty Officer - Central North Minnesota', 'Duty Officer - Back-up - Central North Minnesota']],
      ['South Minnesota', ['Duty Officer - South Minnesota', 'Duty Officer - Back-up - South Minnesota']],
      ['Dakotas', ['Duty Officer - Dakotas', 'Duty Officer - Back-up - Dakotas']],
      ['Region', ['Regional Leadership On Call', 'Regional Disaster Officer']],
    ]

    shift_times = Scheduler::ShiftTime.current_groups_for_region(mn)

    shift_assignments = shift_names.map {|shift_territory_name, shift_names|
      s_t = Roster::ShiftTerritory.where(name: shift_territory_name, region: mn).first
      shift_assignments = shift_names.map {|shift_name|
        s = Scheduler::Shift.where(name: shift_name, shift_territory: s_t).first
        Scheduler::ShiftAssignment.where(shift_time: shift_times, shift: s).for_day(mn.time_zone.today).to_a
      }

      [shift_territory_name, shift_assignments]
    }
  end
end
