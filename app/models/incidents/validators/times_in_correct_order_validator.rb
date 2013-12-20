class Incidents::Validators::TimesInCorrectOrderValidator < ActiveModel::Validator
  MESSAGE = "%s must come before %s"
  def validate(record)
    fields = record.incident.timeline_mandatory_keys
    fields.each_index do |idx|
      next if idx == 0
      first_evt = fields[idx-1]
      second_evt = fields[idx]
      if record.send( first_evt ).try(:>, record.send(second_evt))
        record.errors.add(second_evt, MESSAGE % [first_evt.to_s.titleize, second_evt.to_s.titleize])
      end
    end
  end
end