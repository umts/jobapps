require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_application_templates.haml' do
  before :each do
    @department = create :department
    assign :departments, Array(@department)
    @position = create :position, department: @department
    assign :positions, Array(@position)
  end
  context 'there are application templates present' do
    before :each do
      @application_template = create :application_template, position: @position
    end
    it 'contains a link to view the application template' do
      render
      action_path = application_template_path @application_template
      expect(rendered).to have_tag 'a', with: { href: action_path }
    end
    it 'contains a link to edit the application template' do
      render
      action_path = edit_application_template_path @application_template
      expect(rendered).to have_tag 'a', with: { href: action_path }
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
