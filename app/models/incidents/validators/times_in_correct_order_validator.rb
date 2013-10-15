class Incidents::Validators::TimesInCorrectOrderValidator < ActiveModel::Validator
  MESSAGE = "%s must come before %s"
  def validate(record)
    return false unless record.responder_notified and record.responder_arrived and record.responder_departed
    [[:responder_notified, :responder_arrived], [:responder_arrived, :responder_departed]].each do |first_evt, second_evt|
      if record.send( first_evt ) > record.send(second_evt)
        record.errors[second_evt] = MESSAGE % [first_evt.to_s.titleize, second_evt.to_s.titleize]
      end
    end
  end
end