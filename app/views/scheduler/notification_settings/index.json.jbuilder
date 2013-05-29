json.array!(collection) do |scheduler_notification_setting|
  json.extract! scheduler_notification_setting, :person_id, :email_advance_hours, :sms_advance_hours, :sms_only_after, :sms_only_before
  json.url scheduler_notification_setting_url(scheduler_notification_setting, format: :json)
end