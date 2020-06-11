
class Scheduler::CalendarController < Scheduler::BaseController
  skip_authorization_check

  respond_to :html

  #before_action :require_xhr, only: [:day, :month]

  def show
    @date = @month = month_param
    params[:show_shifts] = 'shift_territory' if params[:display]

    load_calendar @month, @month.next_month
    view = params[:display] || 'show'

    case view
    when 'spreadsheet', 'show'
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
    @calendar = Scheduler::Calendar.new(current_region, start_date, end_date, person: person, filter: show_shifts, shift_territories: show_shift_territories, categories: show_categories)
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
    ["DAT", spreadsheet_shift_territory.try(:abbrev), @month.strftime("%Y"), @month.strftime("%b")].compact.join "-"
  end

  helper_method :person, :show_shift_territories, :show_shifts, :show_categories,
        :can_take_shift?, :spreadsheet_groups, :spreadsheet_shift_territory

  attr_reader :calendar, :date
  helper_method :calendar, :date

  def person
    return @_person if defined?(@_person)

    @_person = if params[:person_id].nil?
      current_user
    elsif params[:person_id].blank?
      nil
    else
      Roster::Person.for_region(current_region).includes(:shift_territories).where(id: params[:person_id]).first!
    end

    return @_person
  end

  def show_shift_territories
    @_show_shift_territories ||= if params[:shift_territories].present?
      Array(params[:shift_territories]).select(&:present?).map(&:to_i)
    elsif person 
      [person.primary_shift_territory_id]
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
    when 'shift_territory' then :shift_territory
    when 'all' then :all
    else :mine
    end
  end

  def spreadsheet_shift_territory
    @_spreadsheet_shift_territory ||= (show_shift_territories.present? && Roster::ShiftTerritory.find( show_shift_territories.first))
  end

  def spreadsheet_groups
    @_spreadsheet_groups ||= Scheduler::ShiftTime.where(period: 'daily').reduce({}) do |hash, group|
      hash[group] = group.shifts.where(shift_territory_id: spreadsheet_shift_territory).where('spreadsheet_ordinal is not null').order(:spreadsheet_ordinal)
      hash
    end
  end

  def month_param
    Date.strptime("#{params[:year]} #{params[:month]}", "%Y %B")
  end
end
