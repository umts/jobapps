# frozen_string_literal: true

module ApplicationHelper
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

  def site_contact_email
    app_config.email[:site_contact_email]
  end

  def should_show_denied_applications?
    app_config.on_application_denial[:notify_applicant]
  end

  def should_show_denial_reason?
    app_config.on_application_denial[:notify_of_reason]
  end

  def allow_resubmission?
    app_config.on_application_denial[:allow_resubmission]
  end

  def should_allow_form_refilling?
    app_config.on_application_denial[:fill_form_with_old]
  end

  private

  def app_config
    Rails.configuration.x.app
  end
end
