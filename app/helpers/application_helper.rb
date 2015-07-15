module ApplicationHelper
  include ApplicationConfiguration
  include DateAndTimeMethods

  def configured_organization_name
    configured_value [:organization_name]
  end

  def render_markdown(text)
    renderer = Redcarpet::Render::HTML
    markdown = Redcarpet::Markdown.new renderer
    markdown.render(text).html_safe
  end

  def should_show_denied_applications?
    configured_value [:on_application_denial, :notify_applicant], default: true
  end

  def text(name)
    text = SiteText.where(name: name).first.try :text
    render_markdown text if text.present?
  end
end
