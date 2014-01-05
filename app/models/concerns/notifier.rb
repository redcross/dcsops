module Notifier
  extend ActiveSupport::Concern

  included do
    cattr_accessor :notification_type, :role_grant_name
  end

  def notification_subscribers
    self.notification_type && Incidents::NotificationSubscription.for_chapter(self.chapter).for_county(self.notification_scope).for_type(self.notification_type).includes{person}.map(&:person) || []
  end

  def role_subscribers
    self.role_grant_name && Roster::Person.for_chapter(self.chapter).has_role_for_scope(self.role_grant_name, self.role_scope) || []
  end

  def notify
    to_notify.each do |person|
      yield person
    end
  end

  def notification_type
    self.class.notification_type
  end

  def role_grant_name
    self.class.role_grant_name
  end

  def additional_notifications
    []
  end

  def to_notify

    arr = []

    arr += notification_subscribers
    arr += role_subscribers
    arr += additional_notifications
    arr.uniq
  end
end