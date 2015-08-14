require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_templates/show.haml' do
  before :each do
    @template = create :application_template
    assign :template, @template
  end
  let :action_path do
    application_records_path
  end
  context 'current user is present' do
    before :each do
      @current_user = create :user
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
      it 'does not downcase capitalized question prompts' do
        create :question, application_template: @template, prompt: 'A Prompt'
        render
        expect(rendered).to have_form action_path, :post do
          with_text_field 'responses[A Prompt]' do
            with_text 'A Prompt'
          end
        end
      end
    end
    context 'current user is staff' do
      before :each do
        when_current_user_is :staff, view: true
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
