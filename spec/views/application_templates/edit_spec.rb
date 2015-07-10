require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_templates/edit.haml' do
  before :each do
    @template = create :application_template
    @top_question = create :question, application_template: @template
    @middle_question = create :question, application_template: @template
    @bottom_question = create :question, application_template: @template
  end
  it 'includes a link to view application' do
    render
    action_path = application_template_path @template
    expect(rendered).to have_tag 'a', with: { href: action_path }
  end
  it 'contains a form with questions' do
    render
    action_path = question_path @top_question
    expect(rendered).to have_form action_path, :post
  end
  it 'has a prompt that is required' do
    render
    action_path = question_path @top_question
    expect(rendered).to have_form action_path, :post do
      with_text_area 'question[prompt]'
    end
  end
  it 'contains options to select data type' do
    render
    action_path = question_path @top_question
    expect(rendered).to have_form action_path, :post do
      with_select 'question[data_type]'
    end
  end
  it 'contains a check box to determine whether question is required' do
    render
    action_path = question_path @top_question
    expect(rendered).to have_form action_path, :post do
      with_checkbox 'question[required]'
    end
  end
  it 'has a submit button to save the question' do
    render
    action_path = question_path @top_question
    expect(rendered).to have_form action_path, :post do
      with_submit 'Save question'
    end
  end
  it 'contains a form to add a new question' do
    render
    expect(rendered).to have_form questions_path, :post
  end
  it 'shows a button to move up if button is in middle' do
    render
    action_path = move_question_path @middle_question, direction: :up
    expect(rendered).to have_form action_path, :post
  end
  it 'shows a button to move down if button is in middle' do
    render
    action_path = move_question_path @middle_question, direction: :down
    expect(rendered).to have_form action_path, :post
  end
  it 'does not have a button to move up if top question' do
    render
    action_path = move_question_path @top_question, direction: :up
    expect(rendered).not_to have_form action_path, :post
  end
  it 'has a button to move down if top question' do
    render
    action_path = move_question_path @top_question, direction: :down
    expect(rendered).to have_form action_path, :post
  end
  it 'does not have a button to move down if bottom question' do
    render
    action_path = move_question_path @bottom_question, direction: :down
    expect(rendered).not_to have_form action_path, :post
  end
  it 'has a button to move up if bottom question' do
    render
    action_path = move_question_path @bottom_question, direction: :up
    expect(rendered).to have_form action_path, :post
  end
end
