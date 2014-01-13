
class Scheduler::CalendarController < Scheduler::BaseController
  before_filter :authorize_resource
  skip_authorization_check

  respond_to :html, :pdf

  responders :pdf

  def show
    @month = month_param
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)

    params[:show_shifts] = :county if params[:display]

    @calendar = Scheduler::Calendar.new(current_chapter, @month, @month.next_month, person: person, filter: show_shifts, counties: show_counties)

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
    @editable = can? :create, Scheduler::ShiftAssignment.new( person: person)

    if params[:date]
      date = end_date = Date.strptime(params[:date], "%Y-%m-%d")
      partial_name = params[:period] || 'day'
    else
      date = Date.strptime(params[:month], "%Y-%m")
      end_date = date.next_month
      partial_name = 'month'
    end

    raise "Invalid period" unless %w(day week monthly month).include? partial_name

    @calendar = Scheduler::Calendar.new(current_chapter, date, end_date, person: person, filter: show_shifts, counties: show_counties)

    unless request.xhr? or params[:partial].present?
      redirect_to scheduler_calendar_path(date.year, date.strftime("%B").downcase) and return
    end

    render partial: partial_name, locals: {editable: @editable, month: date, date: date}
  end

  private

  def pdf_file_name
    ["DAT", spreadsheet_county.try(:abbrev), @month.strftime( "%Y"), @month.strftime("%b")].compact.join "-"
  end

  


  def authorize_resource
    #authorize! :read, Scheduler::ShiftAssignment.new(person: person)
  end

  helper_method :person, :show_counties, :show_shifts, :show_only_available,
        :can_take_shift?, :show_county_name, :ajax_params, :spreadsheet_groups, :spreadsheet_county

  attr_reader :calendar
  helper_method :calendar

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

  def show_counties
    @_show_counties ||= ((params[:counties].is_a?(Array) && params[:counties].select(&:present?).map(&:to_i)) || (person ? [person.primary_county_id] : [])).compact
  end

  def show_shifts
    params[:show_shifts] && params[:show_shifts].to_sym || :mine
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
    calendar.all_groups.flat_map{|_, shifts| shifts.map(&:county_id)}.uniq.count > 1
  end

  def ajax_params
    {
      person_id: person.try(:id),
      show_shifts: show_shifts,
      counties: show_counties
    }
  end

  def month_param
    Date.strptime("#{params[:year]} #{params[:month]}", "%Y %B")
  end
end
