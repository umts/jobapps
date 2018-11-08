# Generic date and time methods, included in ApplicationController by default.
module DateAndTimeMethods
  def format_date_time(datetime, options = {})
    case options[:format]
    when :iCal then datetime.utc.strftime '%Y%m%dT%H%M%SZ'
    else datetime.strftime '%A, %B %e, %Y - %l:%M %P'
    end.squish
  end

  def format_date(date)
    date.strftime '%A, %B %-d, %Y'
  end

  def parse_american_date(date)
    Date.strptime(date, '%m/%d/%Y')
  end
end
