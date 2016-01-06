module ApplicationHelper
  include ApplicationConfiguration
  include DateAndTimeMethods

  def configured_organization_name
    configured_value [:organization_name]
  end

  def parse_application_data(data)
    questions = []
    data.each do |k, v|
      match_data = k.match(/^(prompt|response|data_type)_(\d+)$/)
      next unless match_data.present?
      input_type, number = match_data.captures
      questions[number.to_i] ||= []
      input_types = %w(prompt response data_type)
      index = input_types.index input_type
      questions[number.to_i][index] = v
    end
    questions
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
