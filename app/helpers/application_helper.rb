# frozen_string_literal: true

module ApplicationHelper
  include ApplicationConfiguration

  def configured_organization_name
    configured_value [:organization_name]
  end

  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true)
    markdown = Redcarpet::Markdown.new renderer
    # This cop is to warn developers of the possible dangers of using html_safe
    # because it will, by definition, allow injecting user-input into the DOM.
    # However, the filter_html: true option above prevents users from entering
    # in their own tags. Thus, ignore this cop, it has done its job.
    # rubocop:disable Rails/OutputSafety
    markdown.render(text).html_safe
    # rubocop:enable Rails/OutputSafety
  end

  def should_show_denied_applications?
    configured_value %i[on_application_denial notify_applicant], default: true
  end

  def allow_resubmission?
    configured_value %i[on_application_denial allow_resubmission],
                     default: true
  end

  def should_allow_form_refilling?
    configured_value %i[on_application_denial fill_form_with_old],
                     default: true
  end
end
