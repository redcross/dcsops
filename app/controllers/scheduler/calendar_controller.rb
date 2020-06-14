
class Scheduler::CalendarController < Scheduler::BaseController
  skip_authorization_check

  respond_to :html

  #before_filter :require_xhr, only: [:day, :month]

  def show
    @date = @month = month_param
    params[:show_shifts] = 'county' if params[:display]

    load_calendar @month, @month.next_month
    view = params[:display] || 'show'

    case view
    when 'spreadsheet', 'grid', 'show'
      respond_with 1, {filename: pdf_file_name, template: "scheduler/calendar/#{view}.html.haml"}
    when 'open_shifts'
      render partial: 'open_shifts', locals: {month: @month, groups: calendar.daily_groups}
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def day
    @date = Date.strptime(params[:date], "%Y-%m-%d")

    load_calendar date, date
    render partial: calendar_partial_name, locals: {editable: editable?, date: date}
  end

  def month
    @date = Date.strptime(params[:month], "%Y-%m")
    end_date = date.next_month

    load_calendar date, end_date
    render partial: 'month', locals: {editable: editable?, month: date}
  end

  private

  def load_calendar(start_date, end_date)
    @calendar = Scheduler::Calendar.new(current_region, start_date, end_date, person: person, filter: show_shifts, counties: show_counties, categories: show_categories)
  end    

  helper_method :editable?
  def editable?
    person && can?(:create, Scheduler::ShiftAssignment.new(person: person))
  end

  def require_xhr
    unless request.xhr? or params[:partial].present?
      redirect_to scheduler_calendar_path(Date.current.year, Date.current.strftime("%B").downcase)
    end
  end

  def calendar_partial_name
    case params[:period]
    when 'day' then 'day'
    when 'week' then 'week'
    when 'monthly' then 'monthly'
    else 'day'
    end
  end

  def pdf_file_name
    ["DAT", spreadsheet_county.try(:abbrev), @month.strftime("%Y"), @month.strftime("%b")].compact.join "-"
  end

  helper_method :person, :show_counties, :show_shifts, :show_categories,
        :can_take_shift?, :spreadsheet_groups, :spreadsheet_county

  attr_reader :calendar, :date
  helper_method :calendar, :date

  def person
    return @_person if defined?(@_person)

    @_person = if params[:person_id].nil?
      current_user
    elsif params[:person_id].blank?
      nil
    else
      Roster::Person.for_region(current_region).includes(:counties).where(id: params[:person_id]).first!
    end

    return @_person
  end

  def show_counties
    @_show_counties ||= if params[:counties].present?
      Array(params[:counties]).select(&:present?).map(&:to_i)
    elsif person 
      [person.primary_county_id]
    else
      []
    end.compact
  end

  def show_categories
    @_show_categories ||= if params[:categories].present?
      Array(params[:categories]).select(&:present?).map(&:to_i)
    else
      Scheduler::ShiftCategory.for_region(current_region).where{show == true}.ids
    end
  end

  def show_shifts
    case params[:show_shifts]
    when 'county' then :county
    when 'all' then :all
    else :mine
    end
  end

  def spreadsheet_county
    @_spreadsheet_county ||= (show_counties.present? && Roster::County.find( show_counties.first))
  end

  def spreadsheet_groups
    @_spreadsheet_groups ||= Scheduler::ShiftTime.where(period: 'daily').reduce({}) do |hash, group|
      hash[group] = group.shifts.where(county_id: spreadsheet_county).where('spreadsheet_ordinal is not null').order(:spreadsheet_ordinal)
      hash
    end
  end

  def month_param
    Date.strptime("#{params[:year]} #{params[:month]}", "%Y %B")
  end
end
