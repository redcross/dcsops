class Incidents::TimelineProxy
  include ActiveModel::Validations

  validates_with Incidents::Validators::TimesInCorrectOrderValidator

  attr_accessor :incident, :fields

  validate :validate_mandatory_fields

  EVENT_TYPES = Incidents::EventLog::EVENT_TYPES.keys.reject{|v| %w(note dispatch_note).include? v}

  def initialize(incident, mandatory_fields=[])
    @incident = incident
    @fields = mandatory_fields
  end

  def event_log_for(type, create: false)
    type = type.to_s
    raise ArgumentError, "#{type} is not a legal event log type" unless EVENT_TYPES.include?(type)
    incident.event_logs.detect{|l| l.event == type && !l.marked_for_destruction?} || (create && incident.event_logs.build(event: type))
  end

  EVENT_TYPES.each do |type|
    define_method type do
      event_log_for(type).try(:event_time)
    end

    define_method "#{type}=" do |val|
      parsed_time = case val
      when "" then nil
      when String then Time.zone.parse(val)
      else val
      end
      if parsed_time
        event_log_for(type, create: true).event_time = parsed_time
      else
        event_log_for(type).try(:mark_for_destruction)
      end
    end
  end

  def attributes
    EVENT_TYPES.map{|t| {t: event_log_for(type).try(:event_time)}}.reduce(&:merge)
  end

  def attributes=(attrs)
    attrs.each do |key, val|
      self.send "#{key}=", val
    end
  end

  def persisted?
    false
  end

  def marked_for_destruction?
    false
  end

  def validate_mandatory_fields
    fields.each do |f|
      f = f.to_sym
      log = event_log_for(f)
      if !log
        self.errors.add(f, :blank)
      end
      if log and log.invalid?
        self.errors.add(f, :invalid)
      end
    end
  end

end