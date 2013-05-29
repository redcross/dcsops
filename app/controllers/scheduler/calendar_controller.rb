class Scheduler::CalendarController < Scheduler::BaseController
  before_filter :authorize_resource

  def show
    @month = month_param
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)

    case params[:display]
    when 'spreadsheet'
      render action: 'spreadsheet'
    when 'open_shifts'
      render partial: 'open_shifts', locals: {month: @month, groups: daily_groups}
    else
      render action: 'show'
    end
  end

  def day
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)
    #@daily_groups = Scheduler::ShiftGroup.where(period: 'daily')

    if params[:date] and date = Date.strptime(params[:date], "%Y-%m-%d")
      render partial: 'day', locals: {date: date, editable: @editable}
    elsif params[:month] and date = Date.strptime(params[:month], "%Y-%m")
      render partial: 'month', locals: {month: date, editable: @editable}
    end
  end

  def open_shifts
    @month = month_param
    @daily_groups = Scheduler::ShiftGroup.where(period: 'daily')

    
  end

  private

  def authorize_resource
    authorize! :read, person
  end

  helper_method :person, :show_counties, :show_shifts, :daily_groups, :can_take_shift?, :show_county_name, :ajax_params, :spreadsheet_groups, :spreadsheet_county
  def person
    @_person ||= if params[:person_id].nil?
      current_user
    elsif params[:person_id].blank?
      nil
    else
      Roster::Person.find params[:person_id]
    end
  end

  def show_counties
    @_show_counties ||= ((params[:counties].is_a?(Array) && params[:counties].map(&:to_i)) || (person ? person.county_ids : []))
  end

  def show_shifts
    params[:show_shifts] && params[:show_shifts].to_sym || :mine
  end

  def daily_groups
    @_daily_groups ||= filter_shifts Scheduler::ShiftGroup.where(period: 'daily')
  end

  def spreadsheet_county
    Roster::County.find show_counties.first
  end

  def spreadsheet_groups
    Scheduler::ShiftGroup.where(period: 'daily').reduce({}) do |hash, group|
      hash[group] = group.shifts.where(county_id: spreadsheet_county).where('spreadsheet_ordinal is not null').order(:spreadsheet_ordinal)
      hash
    end
  end

  def show_county_name
    daily_groups.map{|_, shifts| shifts.map(&:county_id)}.flatten.uniq.count > 1
  end

  def can_take_shift?(shift)
    if person and person.counties.include? shift.county
      pos = shift.positions & person.positions
      return !pos.blank?
    end
    false
  end

  def ajax_params
    {
      person_id: person.try(:id),
      show_shifts: show_shifts,
      counties: show_counties
    }
  end

  def filter_shifts(groups)
    groups.inject({}){|hash, group|
      shifts = case show_shifts
      when :all then group.shifts
      when :county then group.shifts.select{|s| show_counties.include? s.county_id}
      when :mine then group.shifts.select{|s| can_take_shift? s}
      end
      hash[group] = shifts
      hash
    }
  end

  def month_param
    Date.strptime("#{params[:year]} #{params[:month]}", "%Y %B")
  end
end
