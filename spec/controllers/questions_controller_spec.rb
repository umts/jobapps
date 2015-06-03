require 'rails_helper'

describe QuestionsController do
  describe 'POST #create' do
    before :each do
      @question = attributes_with_foreign_keys_for :question 
      @path = 'http://test.host/redirect'
    end
    let :submit do
      request.env['HTTP_REFERER'] = @path
      post :create, question: @question 
    end
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized 
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      context 'invalid input' do
        before :each do
          @question = {number: ''}  
        end
        it 'displays errors' do
          submit
          expect(flash.keys).to include 'errors'
        end
        it 'redirects back' do
          expect_redirect_to_back(@path){submit}
        end
      end
      context 'valid input' do
        it 'creates a question as specified' do
          expect{submit}.to change{Question.count}.by 1
        end
        it 'displays a message' do
          submit
          expect(flash.keys).to include 'message' 
        end
        it 'redirects back' do
          expect_redirect_to_back(@path){submit}
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      #establish parameters
    end
    let :submit do
      #submit request to controller action
    end
    context 'student' do
      it 'does not allow access'
    end
    context 'staff' do
      before :each do
        #establish staff current user
      end
      it 'destroys the question'
      it 'displays a flash message'
      it 'redirects back'
    end
  end

  describe 'POST #move' do
    before :each do
      @question = create :question
    end
    let :submit do
      post :move, id: @question.id, direction: @direction
    end
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      context 'moving up' do
        before :each do
          @direction = 'up'
        end
        #expect the controller to call #move on the question with :up as an argument
        it 'calls #move with :up'
        it 'redirects back' do
          expect_redirect_to_back{submit}
        end
      end
      context 'moving down' do
        before :each do
          @direction = 'down'
        end
        #expect the controller to call #move on the question with :up as an argument
        it 'calls #move with :down'
        it 'redirects back' do
          expect_redirect_to_back{submit}
        end
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      #establish parameters
    end
    let :submit do
      #submit request to controller action
    end
    context 'student' do
      it 'does not allow access'
    end
    context 'staff' do
      before :each do
        #establish staff current user
      end
      context 'invalid input' do
        it 'shows errors'
        it 'redirects back'
      end
      context 'valid input' do
        it 'updates the question as specified'
        it 'displays a message'
        it 'redirects back'
      end
    end
  end
end
