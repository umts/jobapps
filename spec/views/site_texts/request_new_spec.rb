require 'rails_helper'
include RSpecHtmlMatchers

describe 'site_texts/request_new.haml' do
  it 'has a form to post to its own action with location and description' do
    action_path = request_new_site_texts_path
    render
    expect(rendered).to have_form action_path, :post do
      with_tag 'textarea', with: { required: 'required', name: 'location' }
      with_tag 'textarea', with: { required: 'required', name: 'description' }
    end
  end
end
