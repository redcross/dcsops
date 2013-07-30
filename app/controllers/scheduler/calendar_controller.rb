class Scheduler::CalendarController < Scheduler::BaseController

  before_filter :authorize_resource
  skip_authorization_check

  acts_as_flying_saucer

  respond_to :html, :pdf

  def show
    @month = month_param
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)

    params[:show_shifts] = :county if params[:display]

    load_shifts(@month, @month.next_month)
    load_my_shifts(@month, @month.next_month)

    case params[:display]
    when 'spreadsheet', 'grid'
      respond_to do |fmt|
        fmt.pdf { 
          render_pdf template: "scheduler/calendar/#{params[:display]}.html.haml", send_file: {type: :pdf, filename: pdf_file_name, disposition: 'inline'}
        }
        fmt.html { render action: params[:display] }
      end
    when 'open_shifts'
      render partial: 'open_shifts', locals: {month: @month, groups: daily_groups}
    else
      respond_to do |fmt|
        fmt.pdf { render_pdf template: "scheduler/calendar/show.html.haml", send_file: {type: :pdf, filename: pdf_file_name, disposition: 'inline'} }
        fmt.html { render action: 'show' }
      end
    end
  end

  def day
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)
    #@daily_groups = Scheduler::ShiftGroup.where(period: 'daily')

    if params[:date] and date = Date.strptime(params[:date], "%Y-%m-%d")
      unless request.xhr? or params[:partial].present?
        redirect_to scheduler_calendar_path(date.year, date.strftime("%B").downcase) and return
      end

      load_shifts(date, date)
      load_my_shifts(date, date)

      partial_name = params[:period] || 'day'
      raise "Invalid period" unless %w(day week monthly).include? partial_name

      render partial: partial_name, locals: {date: date, editable: @editable}
    elsif params[:month] and date = Date.strptime(params[:month], "%Y-%m")
      unless request.xhr? or params[:partial].present?
        redirect_to scheduler_calendar_path(date.year, date.strftime("%B").downcase) and return
      end

      load_shifts(date, date.next_month)
      load_my_shifts(date, date.next_month)
      
      render partial: 'month', locals: {month: date, editable: @editable}
    end
  end

  private

  def pdf_file_name
    ["DAT", spreadsheet_county.try(:abbrev), @month.strftime( "%Y"), @month.strftime("%b")].compact.join "-"
  end

  def load_shifts(date_start, date_end)
    shifts = daily_groups.values.flatten + weekly_groups.values.flatten + monthly_groups.values.flatten
    @all_assignments = Scheduler::ShiftAssignment.includes{person.counties}.includes{shift.county}.includes{shift.positions}
        .where{shift_id.in(shifts) & date.in(date_start.at_beginning_of_week.advance(weeks: -1)..date_end)}
        .order("roster_people.last_name")
    @all_shifts = @all_assignments.reduce({}) do |hash, assignment|
      hash[assignment.shift_id] ||= {}
      hash[assignment.shift_id][assignment.date] ||= []
      hash[assignment.shift_id][assignment.date] << assignment
      hash
    end
  end

  def load_my_shifts(date_start, date_end)
    if person
      group_ids = daily_groups.keys + weekly_groups.keys + monthly_groups.keys
      pid = person.id
      @my_shifts = Scheduler::ShiftAssignment.includes{shift}
          .where{(shift.shift_group_id.in(group_ids)) & (person_id == pid) & date.in(date_start.at_beginning_of_week.advance(weeks: -1)..date_end)}
          .reduce({}) do |hash, assignment|
        hash[assignment.shift.shift_group_id] ||= {}
        hash[assignment.shift.shift_group_id][assignment.date] = assignment
        hash
      end
    else
      @my_shifts = {}
    end
  end


  def authorize_resource
    #authorize! :read, Scheduler::ShiftAssignment.new(person: person)
  end

  helper_method :person, :assignments_for_shift_on_day, :show_counties, :show_shifts, :daily_groups, :weekly_groups, :monthly_groups, :all_groups, :show_only_available,
        :can_take_shift?, :show_county_name, :ajax_params, :spreadsheet_groups, :spreadsheet_county, :my_shift_for_group_on_day
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
    @_show_counties ||= ((params[:counties].is_a?(Array) && params[:counties].select(&:present?).map(&:to_i)) || (person ? [person.primary_county_id] : [])).compact
  end

  def show_shifts
    params[:show_shifts] && params[:show_shifts].to_sym || :mine
  end

  def shifts_by_period(period)
    @_unfiltered_shifts ||= Scheduler::ShiftGroup.includes{[shifts.positions, shifts.county, shifts.shift_group.chapter]}.where(chapter_id: current_user.chapter_id).order(:start_offset).to_a

    @_unfiltered_shifts.select{|sh| sh.period == period}
  end

  def daily_groups
    @_daily_groups ||= filter_shifts(shifts_by_period 'daily')
  end

  def weekly_groups
    @_weekly_groups ||= filter_shifts(shifts_by_period 'weekly')
  end

  def monthly_groups
    @_monthly_groups ||= filter_shifts(shifts_by_period 'monthly')
  end

  def all_groups
    daily_groups.merge(weekly_groups).merge(monthly_groups)
  end

  def spreadsheet_county
    @_spreadsheet_county ||= (show_counties.present? && Roster::County.find( show_counties.first))
  end

  def show_only_available
    params[:only_available] == 'true'
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
    return false unless person
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
      hash[group] = shifts if shifts.present?
      hash
    }
  end

  def month_param
    Date.strptime("#{params[:year]} #{params[:month]}", "%Y %B")
  end
end
