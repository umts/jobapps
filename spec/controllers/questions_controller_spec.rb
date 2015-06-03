require 'rails_helper'

describe QuestionsController do
  describe 'POST #create' do
    before :each do
      # establish parameters
    end
    let :submit do
      # submit request to controller action
    end
    context 'student' do
      it 'does not allow access'
    end
    context 'staff' do
      before :each do
        # establish staff current user
      end
      context 'invalid input' do
        before :each do
          # establish invalid controller input
        end
        it 'displays errors'
        it 'redirects back'
      end
      context 'valid input' do
        it 'creates a question as specified'
        it 'displays a message'
        it 'redirects back'
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      # establish parameters
    end
    let :submit do
      # submit request to controller action
    end
    context 'student' do
      it 'does not allow access'
    end
    context 'staff' do
      before :each do
        # establish staff current user
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
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'moving up' do
        before :each do
          @direction = 'up'
        end
        # expect the controller to call #move on the question
        # with :up as an argument
        it 'calls #move with :up'
        it 'redirects back' do
          expect_redirect_to_back { submit }
        end
      end
      context 'moving down' do
        before :each do
          @direction = 'down'
        end
        # expect the controller to call #move on the question
        # with :down as an argument
        it 'calls #move with :down'
        it 'redirects back' do
          expect_redirect_to_back { submit }
        end
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      # establish parameters
    end
    let :submit do
      # submit request to controller action
    end
    context 'student' do
      it 'does not allow access'
    end
    context 'staff' do
      before :each do
        # establish staff current user
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
