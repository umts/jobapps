require 'rails_helper'

describe ApplicationRecordsController do
  describe 'POST #create' do
    before :each do
      @position = create :position
      @responses = {question: 'answer'}
    end
    let :submit do
      post :create, position_id: @position.id, responses: @responses
    end
    context 'student' do
      before :each do
        set_current_user_to :student
      end
      it 'creates an application record as specified' do
        expect{submit}.to change{ApplicationRecord.count}.by 1
      end
      it 'shows a message' do
        submit
        expect(flash.keys).to include 'message'
      end
      it 'redirects to the student dashboard' do
        submit
        expect(response).to redirect_to student_dashboard_path
      end
    end
    #No reason for staff to use this page
  end

  describe 'POST #review' do
    before :each do
      @record = create :application_record
    end
    #Didn't define a let block since the action takes different
    #parameters under different circumstances
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        post :review, id: @record.id
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      context 'record accepted' do
        let :submit do
          post :review, id: @record.id,
            accepted: 'true',
            interview: {location: 'somewhere', scheduled: 1.day.since.strftime('%Y/%m/%d %H:%M')}
        end
        it 'creates an interview as given' do
          expect{submit}.to change{Interview.count}.by 1
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
          post :review, id: @record.id,
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
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
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
        set_current_user_to :student
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'show'
      end
      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include *%w(record interview)
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'show'
      end
      it 'assigns the correct variables' do
        submit
        expect(assigns.keys).to include *%w(record interview)
      end
    end
  end
end
