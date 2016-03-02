# Generic date and time methods, included in ApplicationController by default.
module DateAndTimeMethods
  def format_date_time(datetime, options = {})
    case options[:format]
    when :iCal then datetime.utc.strftime '%Y%m%dT%H%M%SZ'
    else datetime.strftime '%A, %B %d, %Y - %l:%M %P'
    end
  end

  def parse_american_date(date)
    Date.strptime(date, '%m/%d/%Y')
  end
end
