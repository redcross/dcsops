def date_format name, format
  Time::DATE_FORMATS[name] = format
  Date::DATE_FORMATS[name] = format
  DateTime::DATE_FORMATS[name] = format
end

date_format :dow_short, "%a, %b %e"
date_format :dow_long, "%A, %B %e"
date_format :mdy, "%B %-d %Y"
date_format :date_time, "%-m/%-d %-I:%M%P"
date_format :time, "%-I:%M%P"