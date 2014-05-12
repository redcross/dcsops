# Form model for sending messages
module Incidents::Notifications
  class Message < Struct.new(:id, :event_id, :chapter_id, :message)
    extend ActiveModel::Naming
    include ActiveModel::Validations

    def persisted?; false; end
    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
    def to_key; nil; end
    def event
      Event.find_by(chapter_id: chapter_id, id: event_id)
    end

    validates :event_id, presence: true
  end
end