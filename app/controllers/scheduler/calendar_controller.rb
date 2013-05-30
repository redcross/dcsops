class Scheduler::CalendarController < Scheduler::BaseController
  before_filter :authorize_resource

  def show
    @month = month_param
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)

    load_shifts(daily_groups.values.flatten, @month, @month.next_month)
    load_my_shifts(daily_groups.keys, @month, @month.next_month)

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
      load_shifts(daily_groups.values.flatten, date, date)
      load_my_shifts(daily_groups.keys, date, date)
      render partial: 'day', locals: {date: date, editable: @editable}
    elsif params[:month] and date = Date.strptime(params[:month], "%Y-%m")
      load_shifts(daily_groups.values.flatten, date, date.next_month)
      load_my_shifts(daily_groups.keys, date, date.next_month)
      render partial: 'month', locals: {month: date, editable: @editable}
    end
  end

  def open_shifts
    @month = month_param
    @daily_groups = Scheduler::ShiftGroup.where(period: 'daily')
  end

  private

  def load_shifts(shifts, date_start, date_end)
    @all_shifts = Scheduler::ShiftAssignment.includes{person.counties}.includes{shift.county}.includes{shift.positions}.where{shift_id.in(shifts) & date.in(date_start..date_end)}.reduce({}) do |hash, assignment|
      hash[assignment.shift_id] ||= {}
      hash[assignment.shift_id][assignment.date] ||= []
      hash[assignment.shift_id][assignment.date] << assignment
      hash
    end
  end

  def load_my_shifts(group_ids, date_start, date_end)
    pid = person.id
    @my_shifts = Scheduler::ShiftAssignment.includes{shift}.where{(shift.shift_group_id.in(group_ids)) & (person_id == pid) & date.in(date_start..date_end)}.reduce({}) do |hash, assignment|
      hash[assignment.shift.shift_group_id] ||= {}
      hash[assignment.shift.shift_group_id][assignment.date] = assignment
      hash
    end
  end


  def authorize_resource
    authorize! :read, person
  end

  helper_method :person, :assignments_for_shift_on_day, :show_counties, :show_shifts, :daily_groups, :can_take_shift?, :show_county_name, :ajax_params, :spreadsheet_groups, :spreadsheet_county, :my_shift_for_group_on_day
  def person
    return @_person if @_person

    @_person = if params[:person_id].nil?
      current_user
    elsif params[:person_id].blank?
      nil
    else
      Roster::Person.includes(:counties).where(id: params[:person_id]).first!
    end

    return @_person
  end

  def assignments_for_shift_on_day(shift, date)
    if @all_shifts
      @all_shifts[shift.id].try(:[], date) || []
    else
      Scheduler::ShiftAssignment.where(shift_id: shift, date: date).includes(:person)
    end
  end

  def my_shift_for_group_on_day(group_id, date)
    if @my_shifts
      @my_shifts[group_id].try(:[], date)
    else
      Scheduler::ShiftAssignment.includes(:shift => :shift_group).where(:scheduler_shifts => {shift_group_id: group_id}, person_id: person).where(date: date).first
    end
  end

  def show_counties
    @_show_counties ||= ((params[:counties].is_a?(Array) && params[:counties].map(&:to_i)) || (person ? person.county_ids : []))
  end

  def show_shifts
    params[:show_shifts] && params[:show_shifts].to_sym || :mine
  end

  def daily_groups
    @_daily_groups ||= filter_shifts(Scheduler::ShiftGroup.where(chapter_id: current_user.chapter, period: 'daily').to_a)
  end

  def spreadsheet_county
    @_spreadsheet_county ||= Roster::County.find show_counties.first
  end

  def spreadsheet_groups
    @_spreadsheet_groups ||= Scheduler::ShiftGroup.where(period: 'daily').reduce({}) do |hash, group|
      hash[group] = group.shifts.where(county_id: spreadsheet_county).where('spreadsheet_ordinal is not null').order(:spreadsheet_ordinal)
      hash
    end
  end

  def show_county_name
    daily_groups.map{|_, shifts| shifts.map(&:county_id)}.flatten.uniq.count > 1
  end

  def can_take_shift?(shift)
    @_person_county_ids ||= person.county_ids.to_a
    @_take_shift_cache ||= {}
    @_take_shift_cache[shift.id] ||= if person and @_person_county_ids.include? shift.county_id
      pos = shift.positions & person.positions
      !pos.blank?
    end
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
