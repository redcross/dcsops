class Incidents::Validators::TimesInCorrectOrderValidator < ActiveModel::Validator
  MESSAGE = "%s must come before %s"
  def validate(record)
    fields = record.incident.timeline_mandatory_keys
    fields.each_index do |idx|
      next if idx == 0
      first_evt = record.send fields[idx-1]
      second_evt = record.send fields[idx]
      if first_event and second_event and first_event.event_time > second_event.event_time
        record.errors.add(second_evt, MESSAGE % [first_evt.to_s.titleize, second_evt.to_s.titleize])
      end
    end
  end
end