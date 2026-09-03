# frozen_string_literal: true

module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true)
    markdown = Redcarpet::Markdown.new renderer
    # This cop is to warn developers of the possible dangers of using html_safe
    # because it will, by definition, allow injecting user-input into the DOM.
    # However, the filter_html: true option above prevents users from entering
    # in their own tags. Thus, ignore this cop, it has done its job.
    # rubocop:disable-next Rails/OutputSafety
    markdown.render(text).html_safe
  end
end
