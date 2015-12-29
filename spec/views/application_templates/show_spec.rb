require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_templates/show.haml' do
  before :each do
    @template = create :application_template
    assign :template, @template
    @question = create :question, application_template: @template,
                                  prompt: 'A Prompt'
    @heading = create :question, application_template: @template,
                                 prompt: 'A heading',
                                 data_type: 'heading'
    @explanation = create :question, application_template: @template,
                                     prompt: 'An explanation',
                                     data_type: 'explanation'
  end
  let :action_path do
    application_records_path
  end
  context 'current user is present' do
    before :each do
      @current_user = create :user
    end
    context 'no questions are present' do
      before :each do
        @template = create :application_template # no questions
        assign :template, @template
      end
      it 'shows a message about the application not being available' do
        render
        expect(rendered).to include 'is not currently available'
      end
    end
    it 'pre-fills in the personal information values' do
      render
      expect(rendered).to have_form action_path, :post do
        with_text_field 'user[first_name]', @current_user.first_name
        with_text_field 'user[last_name]', @current_user.last_name
        with_text_field 'user[email]', @current_user.email
      end
    end
    context 'current user is student' do
      before :each do
        when_current_user_is :student, view: true
      end
      it 'contains a form to submit the application' do
        render
        expect(rendered).to have_form action_path, :post
      end
      it 'includes the unique prompt name for headings' do
        render
        expect(rendered).to have_form action_path, :post do
          with_tag 'input', type: 'hidden',
                            value: @heading.unique_prompt_name
        end
      end
      it 'includes the unique prompt name for explanations' do
        render
        expect(rendered).to have_form action_path, :post do
          with_tag 'input', type: 'hidden',
                            value: @explanation.unique_prompt_name
        end
      end
      it 'does not downcase capitalized question prompts' do
        render
        expect(rendered).to have_form action_path, :post do
          with_tag 'label' do
            with_text @question.prompt
          end
        end
      end
    end
    context 'current user is staff' do
      before :each do
        when_current_user_is :staff, view: true
      end
      context 'application is marked as active' do
        it 'has a button to take down the application' do
          @template.active = true
          action_path = toggle_active_application_template_path @template
          render
          expect(rendered).to have_form action_path, :post do
            with_tag :input, with: { type: 'submit', name: 'down' }
          end
        end
      end
      context 'application is marked as inactive' do
        it 'has a button to reactivate the application' do
          @template.active = false
          action_path = toggle_active_application_template_path @template
          render
          expect(rendered).to have_form action_path, :post do
            with_tag :input, with: { type: 'submit', name: 'up' }
          end
        end
      end
      it 'shows the application form with no submit button' do
        render
        expect(rendered).to have_form action_path, :post do
          without_tag :input, with: { type: 'submit' }
        end
      end
    end
  end
end
