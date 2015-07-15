require 'rails_helper'
include RSpecHtmlMatchers

describe 'positions/edit.haml' do
  before :each do
    @position = create :position
  end
  it 'contains a form to edit the position' do
    render
    action_path = position_path @position
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: '_method', value: 'patch' }
    end
  end
  it 'contains a button to remove the position' do
    render
    action_path = position_path @position
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: '_method', value: 'delete' }
    end
  end
end
