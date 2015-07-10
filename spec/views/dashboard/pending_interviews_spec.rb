require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_pending_interviews.haml' do
  context 'there are students with pending interviews' do
    before :each do
      @application_record = create :application_record
      @pending_interview = create :interview,
                                  application_record: @application_record
      @department = create :department
      @position = create :position, department: @department
      assign :departments, Array(@department)
      # maps array pf pending interviews to their positions
      assign :pending_interviews, Hash[@position, Array(@pending_interview)]
    end
    it 'includes a link to any pending interviews' do
      render
      action_path = application_record_path @application_record
      expect(rendered).to have_tag 'a', with: { href: action_path }
    end
  end
  context 'there are no students with pending interviews' do
    before :each do
      @application_record = create :application_record
      @interview = create :interview, application_record: @application_record
      @department = create :department
      @position = create :position, department: @department
      assign :departments, Array(@department)
      assign :pending_interviews, Hash.new
    end
    it 'does not include a link to any pending records' do
      render
      expect(rendered).not_to have_tag 'a'
    end
    it 'says no pending interviews' do
      render
      expect(rendered).to include 'No pending interviews'
    end
  end
end
