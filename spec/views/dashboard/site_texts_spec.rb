require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_site_texts.haml' do
  before :each do
    @site_text = create :site_text
    assign :site_texts, Array(@site_text)
  end
  it 'contains a link to edit the site text' do
    render
    action_path = edit_site_text_path @site_text
    expect(rendered).to have_tag 'a', with: { href: action_path }
  end
  it 'contains a link to request a new site text' do
    render
    action_path = request_new_site_texts_path
    expect(rendered).to have_tag 'a', with: { href: action_path }
  end
end
