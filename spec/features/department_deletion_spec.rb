require 'rails_helper'

describe 'deleting users' do
  before :each do
    when_current_user_is :staff, integration: true
    @dept = create :department
    visit edit_department_path(@dept)
  end

  it 'deletes the department in question' do
    expect { click_on "Remove #{@dept.name}" }
      .to change { Department.count }.by(-1)
    expect(Department.all).not_to include @dept
  end

  it 'redirects you to the staff dashboard' do
    click_on "Remove #{@dept.name}"
    expect(page.current_url).to eql staff_dashboard_url
  end

  it 'gives a flash message' do
    click_on "Remove #{@dept.name}"
    expect(page).to have_selector '#message',
                                  text: 'Department has been deleted.'
  end
end
