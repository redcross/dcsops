def date_format name, format
  Time::DATE_FORMATS[name] = format
  Date::DATE_FORMATS[name] = format
  DateTime::DATE_FORMATS[name] = format
end

date_format :dow_short, "%a, %b %-d"
date_format :dow_long, "%A, %B %-d"
date_format :mdy, "%B %-d %Y"
date_format :date_time, "%-m/%-d %-I:%M%P"
date_format :time, "%-I:%M%P"