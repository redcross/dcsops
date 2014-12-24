class TimeOffsetInput < Formtastic::Inputs::SelectInput
  extend ActiveSupport::Concern

  include ActionView::Helpers::FormOptionsHelper
  def collection
    hour_select_options
  end

  def hour_select_options
    blank = options[:blank].present?
    midnight = options[:midnight].present?
    next_period = options[:next_period].present?
    week = options[:week].present?

    num_days = week ? 7 : 1
    num_days *= 2 if next_period

    end_hour = num_days * 24 - 1

    end_hour += 1 if midnight

    (0..end_hour).map{ |idx| fmt = Time.current.change(hour: 0).advance(hours: idx).strftime("%l:%M %p"); fmt << "+#{idx/24}" if idx >= 24; [fmt, idx*3600]  }.tap{|arr|
      arr.unshift(['', nil]) if blank
    }
  end

end
