require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_templates/edit.haml' do
  before :each do
    @template = create :application_template
  end
  it 'includes a link to view application' do
    render
    action_path = application_template_path @template
    expect(rendered).to have_tag 'a', with: { href: action_path } 
  end
  it 'contains a form with questions' do
    render
    expect(rendered).to have_form 
  end
  it 'has a prompt that is required'
  it 'contains options to select data type'
  it 'contains a check box'
  it 'has a submit button'
  it 'has buttons to move question up'
  it 'has buttons to move question down'
  it 'contains a form to add a new question'
  context 'question is top question' do
    it 'does not have a button to move up'
  end
  context 'question is bottom question' do
    it 'does not have a button to move down'
  end
end
