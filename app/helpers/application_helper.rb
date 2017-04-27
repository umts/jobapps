module ApplicationHelper
  include ApplicationConfiguration
  include DateAndTimeMethods

  def configured_organization_name
    configured_value [:organization_name]
  end

  # A complete question data set might look like:
  # { "prompt_0"    => "What is your name?",
  #   "response_0"  => "Luke Starkiller",
  #   "data_type_0" => "text",
  #   "316"         => "316-1" }
  # which would translate in an application record's data to:
  # ['What is your name?', 'Luke Starkiller', 'text', 316]
  def parse_application_data(data)
    questions = []
    data.each do |key, value|
      input_types = %w[prompt response data_type]
      input_type = input_types.find { |type| key.starts_with? type }
      if input_type.present?
        # the key might be "response_0" (for the first question)
        question_index = key.split('_').last.to_i
        questions[question_index] ||= []
        # the position in the sub-array should match the position in input_types
        input_type_index = input_types.index(input_type)
        questions[question_index][input_type_index] = value
      else
        # the value might be "316-1" (for the first question)
        question_id, question_index = value.split('-').map(&:to_i)
        # questions are numbered starting at 1,
        # but arrays are indexed starting at 0 - so subtract 1
        question_index -= 1
        questions[question_index] ||= []
        # question IDs should go in the fourth position in the sub-array
        questions[question_index][3] = question_id
      end
    end
    questions
  end

  def parse_unavailability(params)
    attrs = Hash.new { |k, v| k[v] = [] }
    params.select { |_, value| value == '1' }
          .keys.each do |day_and_time|
            day, time = day_and_time.split '_'
            attrs[day.to_sym] << time
          end
    attrs
  end

  def render_markdown(text)
    renderer = Redcarpet::Render::HTML
    markdown = Redcarpet::Markdown.new renderer
    markdown.render(text).safe_join
  end

  def should_show_denied_applications?
    configured_value %i[on_application_denial notify_applicant], default: true
  end

  def should_allow_resubmission?
    configured_value %i[on_application_denial allow_resubmission],
                     default: true
  end

  def should_allow_form_refilling?
    configured_value %i[on_application_denial fill_form_with_old],
                     default: true
  end

  def text(name)
    text = SiteText.where(name: name).first.try :text
    render_markdown text if text.present?
  end

  def dashboard_path
    if @current_user.try :staff?
      staff_dashboard_path
    else
      # We still want anonymous logins to redirect to student dashboard
      student_dashboard_path
    end
  end
end
