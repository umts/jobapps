module ApplicationHelper

  MISSING_MESSAGE_VALUE_ERROR = ->(key){raise ArgumentError,
    'Message not given in configuration file and default was not specified.'}

  def show_message key, options = {}
    flash[:message] = CONFIG[:messages][key] ||
      options.fetch(:default, &MISSING_MESSAGE_VALUE_ERROR)
  end

  def render_markdown text
    renderer = Redcarpet::Render::HTML
    markdown = Redcarpet::Markdown.new renderer
    markdown.render(text).html_safe
  end

  def text name
    text = SiteText.where(name: name).first.try :text
    render_markdown text if text.present?
  end
end
