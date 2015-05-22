module ApplicationHelper
  def format_date_time(datetime)
    datetime.strftime 'on %A, %B %e, %Y at %l:%M %P'
  end

  def text name
    text = SiteText.where(name: name).first.try :text
    render_markdown text
  end

  private

  def render_markdown text
    renderer = Redcarpet::Render::HTML
    markdown = Redcarpet::Markdown.new renderer
    markdown.render(text).html_safe
  end
end
