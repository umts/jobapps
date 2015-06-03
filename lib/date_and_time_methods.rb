# Generic date and time methods, included in ApplicationController by default.
module DateAndTimeMethods
  def self.included klass
    klass.extend self
  end

  def format_date_time datetime, options = {}
    case options[:format]
    when :iCal then datetime.utc.strftime '%Y%m%dT%H%M%SZ'
    else datetime.strftime '%A, %B %e, %Y - %l:%M %P'
    end
  end
end
