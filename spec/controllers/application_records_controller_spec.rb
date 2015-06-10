require 'rails_helper'

describe ApplicationRecordsController do
  describe 'POST #create' do
    before :each do
      @position = create :position
      @responses = { question: 'answer' }
    end
    let :submit do
      post :create, position_id: @position.id, responses: @responses
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'creates an application record as specified' do
        expect { submit }
          .to change { ApplicationRecord.count }
          .by 1
      end
      it 'shows the application_receipt message' do
        expect_flash_message :application_receipt
        submit
      end
      it 'redirects to the student dashboard' do
        submit
        expect(response).to redirect_to student_dashboard_path
      end
    end
    # No reason for staff to use this page
  end

  describe 'POST #review' do
    before :each do
      @record = create :application_record
      @interview = { location: 'somewhere',
                     scheduled: 1.day.since.strftime('%Y/%m/%d %H:%M') }
    end
    # Didn't define a let block since the action takes different
    # parameters under different circumstances
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        post :review, id: @record.id
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'record accepted' do
        let :submit do
          post :review,
               id: @record.id,
               accepted: 'true',
               interview: @interview
        end
        it 'creates an interview as given' do
          expect { submit }
            .to change { Interview.count }
            .by 1
        end
        it 'marks record as reviewed' do
          submit
          expect(@record.reload.reviewed).to eql true
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
      context 'record not accepted' do
        let :submit do
          post :review,
               id: @record.id,
               accepted: 'false',
               staff_note: 'because I said so'
        end
        it 'updates record with staff note given' do
          submit
          expect(@record.reload.staff_note).to eql 'because I said so'
        end
        it 'marks record as reviewed' do
          submit
          expect(@record.reload.reviewed).to eql true
        end
        it 'displays application_review message' do
          expect_flash_message :application_review
          submit
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
        context 'notify_applicant set to true' do
          before :each do
            allow_any_instance_of(ApplicationConfiguration)
              .to receive :configured_value
            allow_any_instance_of(ApplicationConfiguration)
              .to receive(:configured_value)
              .with([:on_application_denial, :notify_applicant], anything)
              .and_return true
          end
          it 'sends application denial email to user' do
            expect(JobappsMailer)
              .to receive(:application_denial)
              .with @record
            submit
          end
        end
      end
    end
  end

  describe 'GET #show' do
    before :each do
      @record = create :application_record
    end
    let :submit do
      get :show, id: @record.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'show'
      end
      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include 'record', 'interview'
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'show'
      end
      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include 'record', 'interview'
      end
    end
  end
end
