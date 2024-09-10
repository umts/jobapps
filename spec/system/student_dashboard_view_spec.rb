# frozen_string_literal: true

require 'rails_helper'

describe 'viewing the dashboard as a student' do
  let!(:student) { create(:user, staff: false) }

  before do
    when_current_user_is student
  end

  context 'student has submitted an application' do
    context 'student got an interview' do
      let!(:interview) { create(:interview, user: student) }

      before do
        visit student_dashboard_path
      end

      it 'displays the date, time, and location of any interviews' do
        expect(page).to have_text interview.information
      end

      it 'contains a link to review the application' do
        path = application_submission_path(interview.application_submission)
        click_link 'View your application',
                   href: path
        expect(page.current_path)
          .to eql application_submission_path(interview.application_submission)
      end
    end

    context 'student did not get an interview' do
      let!(:pending_application) do
        create(:application_submission, reviewed: false, user: student)
      end
      let!(:denied_application) do
        create(:application_submission, reviewed: true, user: student, rejection_message: 'No')
      end

      before do
        visit student_dashboard_path
      end

      context 'configured value notify of application denial is true' do
        before do
          stub_config(:on_application_denial, :notify_applicant, true)
        end

        it 'contains a link to review the pending application' do
          click_link 'View your submitted application',
                     href: application_submission_path(pending_application)
          expect(page.current_path)
            .to eql application_submission_path(pending_application)
          expect(page).to have_text 'Your application is pending'
          expect(page).to have_text 'You will be notified'
          expect(page).to have_text 'when your application has been reviewed'
        end

        context 'configured value provide reason is set to false' do
          before do
            stub_config(:on_application_denial, :notify_of_reason, false)
          end

          it 'has link to see denied app, without text of denial reason' do
            click_link 'View your submitted application',
                       href: application_submission_path(denied_application)
            expect(page.current_path)
              .to eql application_submission_path(denied_application)
            expect(page).to have_text 'Your application has been denied.'
            expect(page).to have_no_text 'Reason: No'
          end
        end

        context 'configured value provide reason is set to true' do
          before do
            stub_config(:on_application_denial, :notify_of_reason, true)
          end

          it 'has link to see the denied app, with text of denial reason' do
            click_link 'View your submitted application',
                       href: application_submission_path(denied_application)
            expect(page.current_path)
              .to eql application_submission_path(denied_application)
            expect(page)
              .to have_text 'Your application has been denied. Reason: No'
            # reason is the rejection message
          end
        end
      end

      context 'configured value notify of application denial is false' do
        before do
          stub_config(:on_application_denial, :notify_applicant, false)
        end

        it 'contains a link to review pending applications' do
          click_link 'View your submitted application',
                     href: application_submission_path(pending_application)
          expect(page.current_path)
            .to eql application_submission_path(pending_application)
          expect(page).to have_text 'Your application is pending'
        end

        it 'does not contain a link to review denied applications' do
          action_path = application_submission_path(denied_application)
          expect page.has_no_link? 'View your submitted application',
                                   href: action_path
        end
      end
    end
  end

  context 'student has not yet submitted an application' do
    let!(:position_not_hiring) { create(:position) }

    before do
      visit student_dashboard_path
    end

    context 'position exists, but applications have not been created' do
      context 'user has changed the not hiring text' do
        it 'displays the custom text for the position not hiring' do
          position_not_hiring.update(not_hiring_text: 'custom text')
          visit current_path
          expect(page).to have_text 'custom text'
        end
      end

      context 'user has not edited the not hiring text' do
        it 'displays a boiler-plate not-hiring text' do
          visit current_path
          expect(page)
            .to have_text "not currently hiring for #{position_not_hiring.name}"
        end
      end
    end

    context 'applications have been created for a position, but are inactive' do
      let!(:inactive_app) do
        create(:application_template, active: false, position: position_not_hiring)
      end

      context 'deactivated application text has been edited' do
        it 'displays the custom text for the position not hiring' do
          position_not_hiring.update(not_hiring_text: 'custom text')
          visit current_path
          expect(page).to have_text 'custom text'
        end
      end

      context 'deactivated application text has not been edited' do
        it 'displays the default not-hiring text' do
          visit current_path
          expect(page)
            .to have_text "not currently hiring for #{position_not_hiring.name}"
        end
      end
    end

    context 'applications are active for that position' do
      let!(:active_application) do
        create(:application_template, active: true)
      end

      it 'shows links to submit the application' do
        visit current_path
        # page must be reloaded, as we first visited the page before this
        # application was created
        click_link "Submit application for #{active_application.position.name}"
        expect(page.current_path).to eql application_path(active_application)
      end
    end
  end
end
