# frozen_string_literal: true

require 'rails_helper'

describe InterviewsController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[post complete member],
    %i[post reschedule member],
    %i[get show member]
  ]
  describe 'POST #complete' do
    before :each do
      @interview = create :interview, completed: false
    end
    let :submit do
      post :complete, params: { id: @interview.id }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'hired button is pressed' do
        let :submit do
          post :complete, params: { id: @interview.id, hired: 'anything' }
        end
        it 'marks interview as complete' do
          submit
          expect(@interview.reload).to be_completed
        end
        it 'markes interview as hired' do
          submit
          expect(@interview.reload).to be_hired
        end
      end
      context 'not hired button is pressed' do
        let :submit do
          post :complete, params: { id: @interview.id,
                                    interview_note: 'note' }
        end
        it 'marks the interview as complete' do
          submit
          expect(@interview.reload).to be_completed
        end
        it 'marks interview as not hired' do
          submit
          expect(@interview.reload).not_to be_hired
        end
        it 'adds an interview note to the interview' do
          submit
          expect(@interview.reload.interview_note).to eql 'note'
        end
      end
      context 'with errors' do
        it 'redirects with errors stored in flash' do
          expect_any_instance_of(Interview)
            .to receive(:update)
            .and_return(false)
          expect { submit }.to redirect_back
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
        it 'displays the interview_complete confirmation message' do
          expect_flash_message :interview_complete
          submit
        end
      end
    end
  end

  describe 'POST #reschedule' do
    before :each do
      @interview = create :interview
      @location = 'New location'
      # beginning_of_day to eliminate failures
      # based on the seconds not matching up
      @scheduled = 1.day.since.beginning_of_day
    end
    let :submit do
      post :reschedule, params: {
        id: @interview.id,
        location: @location,
        scheduled: @scheduled.strftime('%Y/%m/%d %H:%M')
      }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'updates interview as specified' do
        submit
        @interview.reload
        expect(@interview.location).to eql @location
        expect(@interview.scheduled).to eql @scheduled
      end
      it 'displays the interview_reschedule confirmation message' do
        expect_flash_message :interview_reschedule
        submit
      end
      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end
      context 'with errors' do
        it 'redirects with errors stored in flash' do
          expect_any_instance_of(Interview)
            .to receive(:update)
            .and_return(false)
          expect { submit }.to redirect_back
          # to have_key won't work here,
          # ActionDispatch::Flash::FlashHash doesn't respond to has_key?
          expect(flash.keys).to include 'errors'
        end
      end
    end
  end

  describe 'GET #show' do
    before :each do
      @interview = create :interview
    end
    let :submit do
      get :show, params: { id: @interview.id, format: :ics }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'does not respond to HTML if so requested' do
        expect { get :show, params: { id: @interview.id, format: :html } }
          .to raise_error ActionController::UnknownFormat
      end
      it 'renders an ICS file if so requested' do
        submit
        expect(response.media_type).to eql 'text/calendar'
      end
    end
  end
end
