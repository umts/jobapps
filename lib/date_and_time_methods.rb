module DateAndTimeMethods

  def format_date_time datetime
    datetime.strftime '%A, %B %e, %Y - %l:%M %P'
  end

end
