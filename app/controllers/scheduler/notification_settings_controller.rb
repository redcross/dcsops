class Scheduler::NotificationSettingsController < Scheduler::BaseController
  respond_to :html, :json
  inherit_resources
  load_and_authorize_resource
  skip_authorize_resource only: :me

  actions :show, :update

  def me
    redirect_to url_for(action: :show, id: current_user.id)
  end

  private

  helper_method :all_sms_phones, :time_periods, :time_periods_for_select, :hour_select_options, :can_see_admin_notifications
  def all_sms_phones
    @_all_sms_phones ||= resource.person.phone_order(sms_only: true).map{|ph| {text: ph[:number], value: ph[:label]}}
  end

  def time_periods
    { "never" => "", "when starting" => 0.to_s, "1 hour before" => 1.hour.to_s, "2 hours before" => 2.hours.to_s, "3 hours before" => 3.hours.to_s, "8 hours before" => 8.hours.to_s, "1 day before" => 1.day.to_s, "2 days before" => 2.days.to_s, "3 days before" => 3.days.to_s}
  end

  def time_periods_for_select
    time_periods.map{|k, v| {text: k, value: v}}
  end

  def hour_select_options(midnight: false, blank: false)
    periods = (0..(midnight ? 24 : 23)).map{ |idx| fmt = (idx==24 ? '11:59 PM' : current_chapter.time_zone.now.change(hour: idx).strftime("%l:%M %p")); {text: fmt, value: idx*3600}  }.tap{|arr|
      arr.unshift( {value: "", text: "never"}) if blank
    }
  end

  def can_see_admin_notifications
    can? :receive_admin_notifications, resource
  end
 
  def resource
    @_resource ||= Scheduler::NotificationSetting.where(id: params[:id]).first_or_create!
  end

  def resource_params
    [params.require(:scheduler_notification_setting).permit({:shift_notification_phones => []}, :sms_advance_hours, :email_advance_hours, :send_email_invites,
        :sms_only_before, :sms_only_after, :email_swap_requested, :email_all_swaps, :email_calendar_signups, :email_all_shifts_at,
        :sms_all_shifts_at, :email_all_swaps_daily)]
  end
end
