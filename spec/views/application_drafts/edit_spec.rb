require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_drafts/edit.haml' do
  before :each do
    @draft = create :application_draft
    assign :draft, @draft
    @top_question = create :question, application_draft: @draft
    @question = create :question, application_draft: @draft
    @bottom_question = create :question, application_draft: @draft
    # questions are needed to test that moving them works
  end
  it 'has a form to edit the draft' do
    render
    action_path = draft_path @draft
    expect(rendered).to have_form action_path, :post do
      with_tag 'form', with: { class: 'edit_draft' }
    end
  end
  it 'has inputs for each question field' do
    render
    expect(rendered).to have_tag 'input' do
      (0...@draft.questions.count).each do |index|
        base_tag_name = "draft[questions_attributes][#{index}]"
        with_hidden_field "#{base_tag_name}[number]"
        with_checkbox "#{base_tag_name}[required]"
      end
    end
    expect(rendered).to have_tag 'textarea' do
      (0...@draft.questions.count).each do |index|
        base_tag_name = "draft[questions_attributes][#{index}]"
        with_text_area "#{base_tag_name}[prompt]"
      end
    end
    expect(rendered).to have_tag 'select' do
      (0...@draft.questions.count).each do |index|
        base_tag_name = "draft[questions_attributes][#{index}]"
        with_select "#{base_tag_name}[data_type]"
      end
    end
  end
  it 'has a button to remove each existing question' do
    render
    action_path = remove_question_draft_path(@draft, number: @question.number)
    expect(rendered).to have_form action_path, :post
  end
  it 'shows a button to move up and down when button is in middle' do
    render
    up_path = move_question_draft_path(@draft, number: @question.number,
                                               direction: :up)
    down_path = move_question_draft_path(@draft, number: @question.number,
                                                 direction: :down)
    expect(rendered).to have_form up_path, :post
    expect(rendered).to have_form down_path, :post
  end
  it 'does not have a button to move up if top question' do
    render
    action_path = move_question_draft_path(@draft, number: @top_question.number,
                                                   direction: :up)
    expect(rendered).not_to have_form action_path, :post
  end
  it 'has a button to move down if top question' do
    render
    action_path = move_question_draft_path(@draft, number: @top_question.number,
                                                   direction: :down)
    expect(rendered).to have_form action_path, :post
  end
  it 'does not have a button to move down if bottom question' do
    render
    action_path = move_question_draft_path(@draft,
                                           number: @bottom_question.number,
                                           direction: :down)
    expect(rendered).not_to have_form action_path, :post
  end
  it 'has a button to move up if bottom question' do
    render
    action_path = move_question_draft_path(@draft,
                                           number: @bottom_question.number,
                                           direction: :up)
    expect(rendered).to have_form action_path, :post
  end
  context 'application template is active' do
    before :each do
      @active_template = create :application_template, active: true
      @draft.update application_template: @active_template
    end
    it 'has a button to deactivate the application' do
      action_path = toggle_active_application_template_url @active_template
      render
      expect(rendered).to have_form action_path, :post do
        with_tag :input, with: { type: 'submit',
                                 value: 'Deactivate application' }
      end
    end
  end
  context 'application template is inactive' do
    before :each do
      @inactive_template = create :application_template, active: false
      @draft.update application_template: @inactive_template
    end
    it 'has a button to reactivate the application' do
      action_path = toggle_active_application_template_url @inactive_template
      render
      expect(rendered).to have_form action_path, :post do
        with_tag :input, with: { type: 'submit',
                                 value: 'Activate application' }
      end
    end
  end
end
