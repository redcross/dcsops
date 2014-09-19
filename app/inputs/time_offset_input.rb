class TimeOffsetInput < Formtastic::Inputs::SelectInput
  extend ActiveSupport::Concern

  include ActionView::Helpers::FormOptionsHelper
  def collection
    hour_select_options
  end

  def hour_select_options
    blank = options[:blank].present?
    midnight = options[:midnight].present?
    next_day = options[:next_day].present?

    end_hour = next_day ? 47 : 23
    end_hour += 1 if midnight

    (0..end_hour).map{ |idx| fmt = Time.current.change(hour: 0).advance(hours: idx).strftime("%l:%M %p"); fmt << "+#{idx/24}" if idx >= 24; [fmt, idx*3600]  }.tap{|arr|
      arr.unshift(['', nil]) if blank
    }
  end

end
