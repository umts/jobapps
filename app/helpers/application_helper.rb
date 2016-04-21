module ApplicationHelper
  include ApplicationConfiguration
  include DateAndTimeMethods

  def configured_organization_name
    configured_value [:organization_name]
  end

  def parse_application_data(data)
    questions = []
    data.each do |k, v|
      match_data = v.match(/^(\d+)\-(\d+)$/) ||
                   k.match(/^(prompt|response|data_type)_(\d+)$/)

      next unless match_data.present?

      input_type, number = match_data.captures
      questions[number.to_i] ||= []
      input_types = %w(prompt response data_type)

      # Because we cannot match "all numeric values" for input_type, we
      # must use a || 3 since if you .index(\d+) it will return nil here
      # which the || 3 will catch.
      index = input_types.index(input_type) || 3
      questions[number.to_i][index] =
        if index == 3 # a.k.a. If it is a numeric number (Q_ID)
          input_type.to_i + 1
        else
          v
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
    configured_value [:on_application_denial, :allow_resubmission],
                     default: true
  end

  def should_allow_form_refilling?
    configured_value [:on_application_denial, :fill_form_with_old],
                     default: true
  end

  def text(name)
    text = SiteText.where(name: name).first.try :text
    render_markdown text if text.present?
  end

  def dashboard_path
    # Just incase this method is called when a current user does not exist
    # return the safe method of a link destination that does not move the
    # page
    return '#' unless @current_user

    if @current_user.staff?
      staff_dashboard_path
    else
      student_dashboard_path
    end
  end
end
