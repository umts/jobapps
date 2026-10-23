# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationSubmissions' do
  let(:record) { create(:application_submission) }

  shared_examples 'a forbidden submission request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /application_submissions' do
    subject(:submit) { post '/application_submissions', params: params }

    let(:position) { create(:position) }
    let(:params) do
      {
        position_id: position.id,
        user: { email: 'applicant@umass.edu' },
        data: {
          'response_1' => 'No',
          'prompt_1' => 'Do you like cats',
          'response_2' => '10/07/2015',
          'prompt_2' => 'Another question',
          'response_3' => '',
          'prompt_3' => 'This thing'
        },
        unavailability: {
          'sunday_7AM' => '0',
          'sunday_8AM' => '0',
          'tuesday_11AM' => '1',
          'tuesday_12AM' => '1',
          'friday_4PM' => '1',
          'friday_5PM' => '0'
        }
      }
    end

    before { create(:application_template, position:, unavailability_enabled: true) }

    shared_examples 'an authorized application submitter' do |role|
      context "with #{role} privilege" do
        let(:user) { create(:user, role) }

        before { when_current_user_is user }

        context 'with valid params' do
          it 'creates an application submission' do
            expect { submit }.to change(ApplicationSubmission, :count).by(1)
          end

          it 'creates the submission for the current user' do
            submit
            expect(ApplicationSubmission.last.user).to eq(user)
          end

          it 'updates the applicant email from the form' do
            submit
            expect(user.reload.email).to eq('applicant@umass.edu')
          end

          it 'creates an unavailability' do
            expect { submit }.to change(Unavailability, :count).by(1)
          end

          it 'redirects to the student dashboard' do
            submit
            expect(response).to redirect_to(student_dashboard_path)
          end
        end

        context 'with an invalid email' do
          let(:params) { super().merge(user: { email: 'applicant@localhost' }) }

          it 'does not create an application submission' do
            expect { submit }.not_to change(ApplicationSubmission, :count)
          end

          it 'does not update the applicant email' do
            expect { submit }.not_to(change { user.reload.email })
          end

          it 'redirects to the root path' do
            submit
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end

    it_behaves_like 'an authorized application submitter', :student
    it_behaves_like 'an authorized application submitter', :staff
    it_behaves_like 'an authorized application submitter', :admin
  end

  describe 'GET /application_submissions/csv_export' do
    subject(:submit) { get '/application_submissions/csv_export.csv', params: params }

    let(:department) { create(:department) }
    let(:params) do
      {
        start_date: 1.week.ago.to_date,
        end_date: Time.zone.today
      }
    end

    shared_examples 'an authorized csv exporter' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        it 'returns a csv content type' do
          submit
          expect(response.media_type).to eq('text/csv')
        end

        context 'with a department id' do
          let(:params) { super().merge(department_ids: [department.id]) }

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized csv exporter', :staff
    it_behaves_like 'an authorized csv exporter', :admin
    it_behaves_like 'a forbidden submission request', :student
  end

  describe 'GET /application_submissions/eeo_data' do
    subject(:submit) { get '/application_submissions/eeo_data', params: params }

    let(:department) { create(:department) }
    let(:params) do
      {
        eeo_start_date: 1.week.ago.to_date,
        eeo_end_date: 1.week.since.to_date
      }
    end

    shared_examples 'an authorized eeo data viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        context 'with a department id' do
          let(:params) { super().merge(department_ids: [department.id]) }

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized eeo data viewer', :staff
    it_behaves_like 'an authorized eeo data viewer', :admin
    it_behaves_like 'a forbidden submission request', :student
  end

  describe 'GET /application_submissions/past_applications' do
    subject(:submit) { get '/application_submissions/past_applications', params: params }

    let(:department) { create(:department) }
    let(:params) do
      {
        records_start_date: 1.week.ago.to_date,
        records_end_date: Time.zone.today
      }
    end

    shared_examples 'an authorized past applications viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        context 'with a department id' do
          let(:params) { super().merge(department_ids: [department.id]) }

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized past applications viewer', :staff
    it_behaves_like 'an authorized past applications viewer', :admin
    it_behaves_like 'a forbidden submission request', :student
  end

  describe 'PATCH /application_submissions/:id/review' do
    subject(:submit) { patch "/application_submissions/#{record.id}/review", params: params }

    let(:interview_params) { { location: 'somewhere', scheduled: 1.day.since } }
    let(:params) { { application_submission: { accepted: 'false' } } }

    shared_examples 'an authorized submission reviewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'when the submission is accepted' do
          let(:params) { { application_submission: { accepted: 'true' }, interview: interview_params } }

          it 'creates an interview' do
            expect { submit }.to change(Interview, :count).by(1)
          end

          it 'creates the interview as given' do
            submit
            expect(record.reload.interview).to have_attributes(location: 'somewhere', user: record.user)
          end

          it 'marks the submission as reviewed' do
            submit
            expect(record.reload.reviewed).to be true
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end

          context 'without interview params' do
            let(:params) { { application_submission: { accepted: 'true' } } }

            it 'returns bad request' do
              submit
              expect(response).to have_http_status(:bad_request)
            end
          end
        end

        context 'when the submission is not accepted' do
          let(:params) do
            { application_submission: { accepted: 'false', staff_note: 'because I said so' } }
          end

          it 'does not create an interview' do
            expect { submit }.not_to change(Interview, :count)
          end

          it 'marks the submission as reviewed' do
            submit
            expect(record.reload.reviewed).to be true
          end

          it 'saves the staff note' do
            submit
            expect(record.reload.staff_note).to eq('because I said so')
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end
      end
    end

    it_behaves_like 'an authorized submission reviewer', :staff
    it_behaves_like 'an authorized submission reviewer', :admin
    it_behaves_like 'a forbidden submission request', :student
  end

  describe 'PATCH /application_submissions/:id/toggle_saved_for_later' do
    subject(:submit) { patch "/application_submissions/#{record.id}/toggle_saved_for_later", params: params }

    let(:record) { create(:application_submission, saved_for_later: false) }
    let(:commit) { 'Save for later' }
    let(:fields) { { note_for_later: 'Call back next week', mail_note_for_later: '0' } }
    let(:params) { { commit: commit, application_submission: fields } }

    shared_examples 'an authorized saved-for-later toggler' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'when saving for later' do
          it 'marks the submission as saved for later' do
            submit
            expect(record.reload.saved_for_later).to be true
          end

          it 'saves the note for later' do
            submit
            expect(record.reload.note_for_later).to eq('Call back next week')
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end

        context 'when removing from saved for later' do
          let(:record) { create(:application_submission, saved_for_later: true, note_for_later: 'A note') }
          let(:commit) { 'Move back to dashboard' }

          it 'marks the submission as not saved for later' do
            submit
            expect(record.reload.saved_for_later).to be false
          end
        end

        context 'without a note for later' do
          let(:fields) { { mail_note_for_later: '1' } }

          it 'does not mark the submission as saved for later' do
            submit
            expect(record.reload.saved_for_later).to be false
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end
      end
    end

    it_behaves_like 'an authorized saved-for-later toggler', :staff
    it_behaves_like 'an authorized saved-for-later toggler', :admin
    it_behaves_like 'a forbidden submission request', :student
  end

  describe 'POST /application_submissions/:id/unreject' do
    subject(:submit) { post "/application_submissions/#{record.id}/unreject" }

    let(:record) { create(:application_submission, reviewed: true) }

    shared_examples 'an authorized submission unrejecter' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'marks the submission as not reviewed' do
          submit
          expect(record.reload.reviewed).to be false
        end

        it 'redirects to the staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end
      end
    end

    it_behaves_like 'an authorized submission unrejecter', :staff
    it_behaves_like 'an authorized submission unrejecter', :admin
    it_behaves_like 'a forbidden submission request', :student
  end

  describe 'GET /application_submissions/:id' do
    subject(:submit) { get "/application_submissions/#{record.id}" }

    let(:record) { create(:application_submission, user: create(:user, :student)) }

    context 'when the current user is the applicant' do
      before { when_current_user_is record.user }

      it 'returns a successful response' do
        submit
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the record belongs to another student' do
      before { when_current_user_is :student }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end

    shared_examples 'an authorized submission viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        it 'generates a pdf when requested' do
          get "/application_submissions/#{record.id}.pdf"
          expect(response.media_type).to eq('application/pdf')
        end
      end
    end

    it_behaves_like 'an authorized submission viewer', :staff
    it_behaves_like 'an authorized submission viewer', :admin
  end
end
