require 'rails_helper'

describe 'viewing the dashboard as a student' do
  let!(:student) { create :user, staff: false }
  before :each do
    when_current_user_is student, integration: true
  end
  context 'student has submitted an application' do
    context 'student got an interview' do
      let!(:interview) { create :interview, user: student }
      before :each do
        visit student_dashboard_url
      end
      it 'displays the date, time, and location of any interviews' do
        expect page.has_text? interview.information
      end
      it 'contains a link to review the application' do
        click_link 'Review your application',
                   href: application_record_path(interview.application_record)
        expect(page.current_url)
          .to eql application_record_url(interview.application_record)
      end
    end # of student got an interview
    context 'student did not get an interview' do
      let!(:pending_application) do
        create :application_record,
               reviewed: false,
               user: student
      end
      let!(:denied_application) do
        create :application_record,
               reviewed: true,
               user: student,
               staff_note: 'No'
      end
      before :each do
        visit student_dashboard_url
      end
      context 'configured value notify of application denial reason is true' do
        before :each do
          allow_any_instance_of(ApplicationConfiguration)
            .to receive :configured_value
          allow_any_instance_of(ApplicationConfiguration)
            .to receive(:configured_value)
            .with([:on_application_denial, :notify_applicant], anything)
            .and_return true
        end
        it 'contains a link to review the pending application' do
          click_link 'Review your application',
                     href: application_record_path(pending_application)
          expect(page.current_url)
            .to eql application_record_url(pending_application)
          expect page.has_text? 'Your application is pending'
          expect page.has_text? 'You will be notified'
          expect page.has_text? 'when your application has been reviewed'
        end
        it 'contains a link to review the denied application' do
          click_link 'Review your application',
                     href: application_record_path(denied_application)
          expect(page.current_url)
            .to eql application_record_url(denied_application)
          expect page.has_text? 'Your application has been denied. Reason: No'
          # reason is the staff note.
        end
      end # of configured value true
      context 'configured value notify of application denial reason is false' do
        before :each do
          allow_any_instance_of(ApplicationConfiguration)
            .to receive :configured_value
          allow_any_instance_of(ApplicationConfiguration)
            .to receive(:configured_value)
            .with([:on_application_denial, :notify_applicant], anything)
            .and_return false
        end
        it 'contains a link to review pending applications' do
          click_link 'Review your application',
                     href: application_record_path(pending_application)
          expect(page.current_url)
            .to eql application_record_url(pending_application)
          expect page.has_text? 'Your application is pending'
        end
        it 'does not contain a link to review denied applications' do
          action_path = application_record_path(denied_application)
          expect page.has_no_link? 'Review your application',
                                   href: action_path
        end
      end # of configured value false
    end # of student did not get an interview
  end # of student has submitted an application
  context 'student has not yet submitted an application' do
    let!(:position_without_application) { create :position }
    let!(:active_application) do
      create :application_template,
             active: true
    end
    let!(:inactive_application) do
      create :application_template,
             active: false
    end
    before :each do
      visit student_dashboard_url
    end
    it 'shows we are not hiring for positions without applications' do
      expect page.has_text? 'We are not currently hiring for the position,'
      expect page.has_text? position_without_application.name.to_s
      expect page.has_text? 'Please check back.'
    end
    it 'shows we are not hiring for applications marked as inactive' do
      expect page.has_text? 'We are not currently hiring for the position,'
      expect page.has_text? inactive_application.position.name.to_s
      expect page.has_text? 'Please check back.'
    end
    it 'shows links to submit an application for the active application' do
      click_link "Submit application for #{active_application.position.name}"
      expect(page.current_url).to eql application_url(active_application)
    end
  end
end
