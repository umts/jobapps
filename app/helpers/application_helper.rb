# frozen_string_literal: true

require 'application_configuration'

module ApplicationHelper
  include ApplicationConfiguration

  def configured_organization_name
    configured_value [:organization_name]
  end

  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true)
    markdown = Redcarpet::Markdown.new renderer
    # rubocop:disable OutputSafety
    # This cop is to warn developers of the possible dangers of using html_safe
    # because it will, by definition, allow injecting user-input into the DOM.
    # However, the filter_html: true option above prevents users from entering
    # in their own tags. Thus, ignore this cop, it has done its job.
    markdown.render(text).html_safe
    # rubocop:enable OutputSafety
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

  def dashboard_path
    if @current_user.try :staff?
      staff_dashboard_path
    else
      # We still want anonymous logins to redirect to student dashboard
      student_dashboard_path
    end
  end
end
