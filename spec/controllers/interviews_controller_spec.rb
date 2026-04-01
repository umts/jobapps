# frozen_string_literal: true

require 'rails_helper'

describe InterviewsController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[post complete member],
    %i[post reschedule member],
    %i[get show member]
  ]

  describe 'POST #complete' do
    let(:interview) { create(:interview, completed: false) }

    let :submit do
      post :complete, params: { id: interview.id }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      context 'when the "hired" button is pressed' do
        let :submit do
          post :complete, params: { id: interview.id, hired: 'anything' }
        end

        it 'marks interview as complete' do
          submit
          expect(interview.reload).to be_completed
        end

        it 'markes interview as hired' do
          submit
          expect(interview.reload).to be_hired
        end
      end

      context 'when the "hired" button is not pressed' do
        let :submit do
          post :complete, params: { id: interview.id, interview_note: 'note' }
        end

        it 'marks the interview as complete' do
          submit
          expect(interview.reload).to be_completed
        end

        it 'marks interview as not hired' do
          submit
          expect(interview.reload).not_to be_hired
        end

        it 'adds an interview note to the interview' do
          submit
          expect(interview.reload.interview_note).to eql 'note'
        end
      end

      context 'with errors' do
        before do
          request.env['HTTP_REFERER'] = '/some/path'
          allow(Interview).to receive(:find).and_return(interview)
          allow(interview).to receive(:update).and_return(false)
        end

        it 'redirects back' do
          expect(submit).to redirect_to('/some/path')
        end

        it 'redirects with errors stored in flash' do
          submit
          # to have_key won't work here,
          # ActionDispatch::Flash::FlashHash doesn't respond to has_key?
          expect(flash.keys).to include 'errors'
        end
      end

      context 'without errors' do
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
    end
  end

  describe 'POST #reschedule' do
    let(:interview) { create(:interview) }
    let(:location) { 'New location' }
    let(:scheduled) { 1.day.from_now.change(sec: 0) }

    let :submit do
      post :reschedule, params: {
        id: interview.id,
        location: location,
        scheduled: scheduled.strftime('%Y/%m/%d %H:%M')
      }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'updates interview as specified' do
        submit
        expect(interview.reload).to have_attributes(location:, scheduled:)
      end

      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end

      context 'with errors' do
        before do
          request.env['HTTP_REFERER'] = '/some/path'
          allow(Interview).to receive(:find).and_return(interview)
          allow(interview).to receive(:update).and_return(false)
        end

        it 'redirects back' do
          expect(submit).to redirect_to('/some/path')
        end

        it 'redirects with errors stored in flash' do
          submit
          # to have_key won't work here,
          # ActionDispatch::Flash::FlashHash doesn't respond to has_key?
          expect(flash.keys).to include 'errors'
        end
      end
    end
  end

  describe 'GET #show' do
    let(:interview) { create(:interview) }

    let :submit do
      get :show, params: { id: interview.id, format: :ics }
    end
    let :calendar_fields do
      response.body.lines.to_h { |l| l.strip.split(':', 2) }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
        submit
      end

      it 'does not respond to HTML if so requested' do
        expect { get :show, params: { id: interview.id, format: :html } }
          .to raise_error(ActionController::UnknownFormat)
      end

      it 'renders an ICS file if so requested' do
        expect(response.media_type).to eql 'text/calendar'
      end

      it 'has a UID' do
        expect(calendar_fields.fetch('UID')).to eq("INTERVIEW#{interview.id}@UMASS_TRANSIT//JOBAPPS")
      end

      it 'has a start time' do
        expect(calendar_fields.fetch('DTSTART')).to eq(interview.scheduled.to_fs(:ical))
      end

      it 'has a summary' do
        expect(calendar_fields.fetch('SUMMARY')).to eq(interview.calendar_title)
      end

      it 'has a description' do
        expect(calendar_fields.fetch('DESCRIPTION'))
          .to match(application_submission_path(interview.application_submission))
      end

      it 'has a stamp' do
        expect(calendar_fields.fetch('DTSTAMP')).to eq(interview.created_at.to_fs(:ical))
      end
    end
  end
end
