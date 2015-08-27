def date_format name, format
  Time::DATE_FORMATS[name] = format
  Date::DATE_FORMATS[name] = format
  DateTime::DATE_FORMATS[name] = format
end

date_format :dow_short, "%a, %b %-d"
date_format :dow_long, "%A, %B %-d"
date_format :mdy, "%B %-d %Y"
date_format :date_time, "%-m/%-d %-I:%M%P"
date_format :mdy_time, "%-m/%-d/%Y %-I:%M%P"
date_format :mdy_time_tz, "%-m/%-d/%Y %-I:%M%P %Z"
date_format :on_date_at_time, "on %-m/%-d at %-I:%M%P"
date_format :time, "%-I:%M%P"
date_format :at_time, "at %-I:%M%P"
date_format :month_year, "%b %Y"

Timeliness.default_timezone = :current
