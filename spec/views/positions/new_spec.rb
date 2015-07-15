require 'rails_helper'
include RSpecHtmlMatchers

describe 'positions/new.haml' do
  before :each do
    @position = create :position
  end
  it 'contains a form to create a new position' do
    render
    action_path = positions_path
    expect(rendered).to have_form action_path, :post do
      with_text_field 'position[name]'
    end
  end
end
