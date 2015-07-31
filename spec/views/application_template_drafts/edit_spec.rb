require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_template_drafts/edit.haml' do
  before :each do
    @template = create :application_template
    @draft = create :application_template_draft, application_template: @template
    @top_question = create :question, application_template_draft: @draft
    @question = create :question, application_template_draft: @draft
    @bottom_question = create :question, application_template_draft: @draft
  end
  it 'has a form to edit the application template draft' do
    render
    action_path = application_template_draft_path @draft
    expect(rendered).to have_form action_path, :post do
      with_tag 'form', with: { class: 'edit_application_template_draft' }
    end
  end
  it 'has inputs for each question field' do
    render
    expect(rendered).to have_tag 'tr' do
      with_hidden_field 'application_template_draft[questions_attributes][0][number]'
      with_text_area 'application_template_draft[questions_attributes][0][prompt]'
      with_select 'application_template_draft[questions_attributes][0][data_type]'
      with_checkbox 'application_template_draft[questions_attributes][0][required]'
    end
  end
  it 'has a button to remove each existing question' do
    render
    action_path = remove_question_application_template_draft_path(@draft,
                                                                  number: @question.number)
    expect(rendered).to have_form action_path, :post
  end
  it 'shows a button to move up and down when button is in middle' do
    render
    up_path = move_question_application_template_draft_path(@draft,
                                                            number: @question.number,
                                                            direction: :up)
    down_path = move_question_application_template_draft_path(@draft,
                                                              number: @question.number,
                                                              direction: :up)
    expect(rendered).to have_form up_path, :post
    expect(rendered).to have_form down_path, :post
  end
  it 'does not have a button to move up if top question' do
    render
    action_path = move_question_application_template_draft_path(@draft,
                                                               number: @top_question.number,
                                                               direction: :up)
    expect(rendered).not_to have_form action_path, :post
  end
  it 'has a button to move down if top question' do
    render
    action_path = move_question_application_template_draft_path(@draft,
                                                                number:  @top_question.number,
                                                                direction: :down)
    expect(rendered).to have_form action_path, :post
  end
  it 'does not have a button to move down if bottom question' do
    render
    action_path = move_question_application_template_draft_path(@draft,
                                                               number: @bottom_question.number,
                                                               direction: :down)
    expect(rendered).not_to have_form action_path, :post
  end
  it 'has a button to move up if bottom question' do
    render
    action_path = move_question_application_template_draft_path(@draft,
                                                          number: @bottom_question.number,
                                                          direction: :up)
    expect(rendered).to have_form action_path, :post
  end
end
