# frozen_string_literal: true

require 'rails_helper'

describe 'Interviews' do
  let(:interview) { create(:interview) }

  shared_examples 'a forbidden interview request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /interviews/:id/complete' do
    subject(:submit) { post "/interviews/#{interview.id}/complete", params: params }

    let(:params) { { hired: 'true' } }

    shared_examples 'an authorized interview completer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'when the applicant was hired' do
          it 'marks the interview as completed' do
            submit
            expect(interview.reload.completed).to be true
          end

          it 'marks the interview as hired' do
            submit
            expect(interview.reload.hired).to be true
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end

        context 'when the applicant was not hired' do
          let(:params) { { interview_note: 'Not a good fit' } }

          it 'marks the interview as completed' do
            submit
            expect(interview.reload.completed).to be true
          end

          it 'marks the interview as not hired' do
            submit
            expect(interview.reload.hired).to be false
          end

          it 'saves the interview note' do
            submit
            expect(interview.reload.interview_note).to eq('Not a good fit')
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end

        context 'when the interview cannot be saved' do
          before do
            allow(Interview).to receive(:find).and_return(interview)
            allow(interview).to receive(:update).and_return(false)
          end

          it 'redirects back to the root path' do
            submit
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end

    it_behaves_like 'an authorized interview completer', :staff
    it_behaves_like 'an authorized interview completer', :admin
    it_behaves_like 'a forbidden interview request', :student
  end

  describe 'POST /interviews/:id/reschedule' do
    subject(:submit) { post "/interviews/#{interview.id}/reschedule", params: params }

    let(:new_scheduled) { 3.days.from_now.change(usec: 0) }
    let(:new_location) { 'New Location' }
    let(:params) { { scheduled: new_scheduled.iso8601, location: new_location } }

    shared_examples 'an authorized interview rescheduler' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'with valid params' do
          it 'updates the scheduled time' do
            submit
            expect(interview.reload.scheduled).to eq(new_scheduled)
          end

          it 'updates the location' do
            submit
            expect(interview.reload.location).to eq(new_location)
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end

        context 'without a scheduled time' do
          let(:params) { { location: new_location } }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end

          it 'does not update the interview' do
            expect { submit }.not_to(change { interview.reload.location })
          end
        end

        context 'without a location' do
          let(:params) { { scheduled: new_scheduled.iso8601 } }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end

          it 'does not update the interview' do
            expect { submit }.not_to(change { interview.reload.scheduled })
          end
        end

        context 'with an invalid scheduled time' do
          let(:params) { { scheduled: 'not a date', location: new_location } }

          it 'does not update the location' do
            expect { submit }.not_to(change { interview.reload.location })
          end

          it 'redirects to the root path' do
            submit
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end

    it_behaves_like 'an authorized interview rescheduler', :staff
    it_behaves_like 'an authorized interview rescheduler', :admin
    it_behaves_like 'a forbidden interview request', :student
  end

  describe 'GET /interviews/:id.ics' do
    subject(:submit) { get "/interviews/#{interview.id}.ics" }

    shared_examples 'an authorized calendar exporter' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        it 'returns a calendar content type' do
          submit
          expect(response.media_type).to eq('text/calendar')
        end

        it 'returns an iCalendar document' do
          submit
          expect(response.body).to include('BEGIN:VCALENDAR')
        end
      end
    end

    it_behaves_like 'an authorized calendar exporter', :staff
    it_behaves_like 'an authorized calendar exporter', :admin
    it_behaves_like 'a forbidden interview request', :student
  end
end
