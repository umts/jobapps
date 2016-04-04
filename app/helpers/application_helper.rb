module ApplicationHelper
  include ApplicationConfiguration
  include DateAndTimeMethods

  def configured_organization_name
    configured_value [:organization_name]
  end

  def parse_application_data(data)
    questions = []
    data.each do |k, v|
      match_data = k.match(/^(prompt|response|data_type)?_?(\d+)$/)
      next unless match_data.present?
      captures = match_data.captures.select{|c| !c.nil? }
      if captures.length == 2
        input_type, number = match_data.captures
        questions[number.to_i] ||= []
        input_types = %w(prompt response data_type)
        index = input_types.index input_type
        questions[number.to_i][index] = v
      elsif captures.length == 1
        q_id, number = v.split('-')
        questions[number.to_i] ||= []
        questions[number.to_i][3] = q_id.to_i + 1
      end
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

  def should_allow_resubmission?
    configured_value [:on_application_denial, :allow_resubmission], default: true
  end

  def should_allow_form_refilling?
    configured_value [:on_application_denial, :fill_form_with_old], default: true
  end

  def text(name)
    text = SiteText.where(name: name).first.try :text
    render_markdown text if text.present?
  end
end
