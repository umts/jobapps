require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_pending_applications.haml' do
  context 'there are students with pending applications' do
    before :each do
      @pending_record = create :application_record
      @department = create :department
      @position = create :position, department: @department
      assign :departments, Array(@department)
      assign :pending_records, Hash[@position, Array(@pending_record)]
    end
    it 'includes a link to any pending applications' do
      render
      action_path = application_record_path @pending_record
      expect(rendered).to have_tag 'a', with: { href: action_path }
    end
  end
  context 'there are no students with pending applications' do
    before :each do
      @department = create :department
      @position = create :position, department: @department
      assign :departments, Array(@department)
      assign :pending_records, Hash.new
    end
    it 'does not include a link to any pending records' do
      render
      expect(rendered).not_to have_tag 'a'
    end
    it 'says no pending applications' do
      render
      expect(rendered).to include 'No pending applications'
    end
  end
end
