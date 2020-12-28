# Wednesday, February 5, 2020
long = '%A, %B %-d, %Y'
Time::DATE_FORMATS[:long] = long
Date::DATE_FORMATS[:long] = long
Time::DATE_FORMATS[:long_with_time] = "#{long} - %-l:%M %P"
Date::DATE_FORMATS[:long_with_time] = "#{long} - %-l:%M %P"

# 20201224T145400Z
Time::DATE_FORMATS[:ical] = ->(time) { time.utc.strftime '%Y%m%dT%H%M%SZ' }
