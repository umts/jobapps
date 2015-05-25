module ApplicationHelper

  def text name
    text = SiteText.where(name: name).first.try :text
    render_markdown text if text.present?
  end

  private

  def render_markdown text
    renderer = Redcarpet::Render::HTML
    markdown = Redcarpet::Markdown.new renderer
    markdown.render(text).html_safe
  end
end
