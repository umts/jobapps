module ApplicationHelper
  def format_date_time(datetime)
    datetime.strftime 'on %A, %B %e, %Y at %l:%M %P'
  end
end
