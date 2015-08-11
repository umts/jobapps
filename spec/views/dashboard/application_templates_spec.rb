require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_application_templates.haml' do
  before :each do
    @department = create :department
    assign :departments, Array(@department)
    @position = create :position, department: @department
    assign :positions, Array(@position)
    when_current_user_is :staff, view: true
  end
  context 'there are application templates present' do
    before :each do
      @template = create :application_template, position: @position
      assign :templates, Array(@template)
    end
    it 'contains a link to view the application template' do
      render
      action_path = application_template_path @template
      expect(rendered).to have_tag 'a', with: { href: action_path }
    end
    context 'there are no existing drafts for that application' do
      it 'contains a link to edit the application' do
        render
        action_path = new_application_template_draft_path(application_template_id: @template.id)
        expect(rendered).to have_tag 'a', with: { href: action_path }
      end
    end
    context 'there are existing drafts for that application' do
      before :each do
        @draft = create :application_template_draft, application_template: @template
      end
      it 'has a link to resume editing the saved draft' do
        render
        action_path = edit_application_template_draft_path @draft
        expect(rendered).to have_tag 'a', with: { href: action_path }
      end
      it 'has a button to discard the saved draft' do
        render
        action_path = application_template_draft_path @draft
        expect(rendered).to have_form action_path, :delete
      end
    end
  end
  context 'there are no application templates for the positions listed' do
    it 'contains a link to create an application' do
      render
      action_path = new_application_template_path(position_id: @position.id)
      expect(rendered).to have_tag 'a', with: { href: action_path }
    end
  end
end
