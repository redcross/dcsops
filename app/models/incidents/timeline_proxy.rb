class Incidents::TimelineProxy
  include ActiveModel::Validations

  #validates_with Incidents::Validators::TimesInCorrectOrderValidator

  attr_reader :incident, :fields

  validate :validate_fields

  EVENT_TYPES = Incidents::EventLog::INCIDENT_EVENT_TYPES.keys.reject{|v| %w(note dispatch_note).include? v}

  def initialize(incident, mandatory_fields=[])
    @incident = incident
    @fields = incident.region.incidents_timeline_mandatory_array(EVENT_TYPES)
  end

  def event_log_for(type, create: false)
    type = type.to_s
    raise ArgumentError, "#{type} is not a legal event log type" unless EVENT_TYPES.include?(type)
    incident.event_logs.detect{|l| l.event == type && !l.marked_for_destruction?} || (create && incident.event_logs.build(event: type))
  end

  EVENT_TYPES.each do |type|
    define_method type do
      event_log_for(type, create: true)
    end

    define_method "#{type}_attributes=" do |attrs|
      if attrs.any?{|k, v| v.present? }
        event_log_for(type, create: true).attributes = attrs
      end
    end
  end

  def attributes
    EVENT_TYPES.map{|t| {t => event_log_for(t).try(:attributes)}}.reduce(&:merge)
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

  def validate_fields
    validate_logs
    validate_mandatory_presence
  end

  def validate_logs
    EVENT_TYPES.each do |type|
      if log = event_log_for(type) and log.invalid?
        self.errors.add(type.to_sym, :invalid)
      end
    end
  end

  def validate_mandatory_presence
    fields.each do |f|
      unless event_log_for(f)
        self.errors.add(f.to_sym, :blank)
      end
    end
  end

end