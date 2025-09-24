# frozen_string_literal: true

require 'rails_helper'

describe 'viewing the dashboard as a student' do
  let!(:student) { create(:user, :student) }

  context 'when student has submitted an application' do
    before do
      when_current_user_is student
    end

    context 'when student got an interview' do
      let!(:interview) { create(:interview, user: student) }

      before do
        visit student_dashboard_path
      end

      it 'displays the date, time, and location of any interviews' do
        expect(page).to have_text(interview.information)
      end

      it 'contains a link to review the application' do
        expect(page).to have_link 'View your application',
                                  href: application_submission_path(interview.application_submission)
      end
    end

    context 'when student did not get an interview' do
      let!(:pending_application) do
        create(:application_submission, reviewed: false, user: student)
      end
      let!(:denied_application) do
        create(:application_submission, reviewed: true, user: student, rejection_message: 'No')
      end

      before do
        visit student_dashboard_path
      end

      context 'when configured value, "notify applicant", is true' do
        before do
          stub_config(:on_application_denial, :notify_applicant, true)
        end

        it 'contains a link to review the pending application' do
          expect(page).to have_link 'View your submitted application',
                                    href: application_submission_path(pending_application)
        end

        it 'informs the applicant that there application is pending' do
          click_link 'View your submitted application',
                     href: application_submission_path(pending_application)
          expect(page).to have_text 'Your application is pending'
        end

        it 'informs the applicant that they will be notified' do
          click_link 'View your submitted application',
                     href: application_submission_path(pending_application)
          expect(page).to have_text 'You will be notified when your application has been reviewed'
        end

        context 'when configured value, "notify of reason", is set to false' do
          before do
            stub_config(:on_application_denial, :notify_of_reason, false)
          end

          it 'informs the applicant of the denial' do
            click_link 'View your submitted application',
                       href: application_submission_path(denied_application)
            expect(page).to have_text 'Your application has been denied.'
          end

          it 'does not inform the applicant why' do
            click_link 'View your submitted application',
                       href: application_submission_path(denied_application)
            expect(page).to have_no_text 'Reason: No'
          end
        end

        context 'when configured value, "notify of reason", is set to true' do
          before do
            stub_config(:on_application_denial, :notify_of_reason, true)
          end

          it 'informs the applicant of the denial' do
            click_link 'View your submitted application',
                       href: application_submission_path(denied_application)
            expect(page).to have_text 'Your application has been denied.'
          end

          it 'informs the applicant why' do
            click_link 'View your submitted application',
                       href: application_submission_path(denied_application)
            expect(page).to have_text 'Reason: No'
          end
        end
      end

      context 'when configured value, "notify applicant", is false' do
        before do
          stub_config(:on_application_denial, :notify_applicant, false)
        end

        it 'contains a link to review pending applications' do
          expect(page).to have_link 'View your submitted application',
                                    href: application_submission_path(pending_application)
        end

        it 'does not contain a link to review denied applications' do
          expect(page).to have_no_link 'View your submitted application',
                                       href: application_submission_path(denied_application)
        end
      end
    end
  end

  context 'when student has not yet submitted an application' do
    let!(:position_not_hiring) { create(:position) }

    before do
      page.set_rack_session(spire: '12345678@umass.edu')
      visit student_dashboard_path
    end

    context 'when a position exists, but applications have not been created' do
      context 'when staff have changed the not-hiring text' do
        it 'displays the custom text for the position not hiring' do
          position_not_hiring.update(not_hiring_text: 'custom text')
          visit current_path
          expect(page).to have_text('custom text')
        end
      end

      context 'when staff have not edited the not-hiring text' do
        it 'displays a boiler-plate not-hiring text' do
          expect(page).to have_text "not currently hiring for #{position_not_hiring.name}"
        end
      end
    end

    context 'when applications have been created for a position, but are inactive' do
      before do
        create(:application_template, active: false, position: position_not_hiring)
      end

      context 'when deactivated application text has been edited' do
        it 'displays the custom text for the position not hiring' do
          position_not_hiring.update(not_hiring_text: 'custom text')
          visit current_path
          expect(page).to have_text('custom text')
        end
      end

      context 'when deactivated application text has not been edited' do
        it 'displays the default not-hiring text' do
          visit current_path
          expect(page).to have_text "not currently hiring for #{position_not_hiring.name}"
        end
      end
    end

    context 'when applications are active for the position' do
      let!(:active_application) do
        create(:application_template, active: true)
      end

      it 'shows links to submit the application' do
        visit current_path
        expect(page).to have_link "Submit application for #{active_application.position.name}"
      end
    end
  end
end
