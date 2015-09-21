require 'rails_helper'

describe ApplicationTemplatesController do
  describe 'GET #bus' do
    before :each do
      when_current_user_is nil
      department = create :department, name: 'Bus'
      position = create :position, department: department, name: 'Operator'
      @template = create :application_template, position: position
    end
    let :submit do
      get :bus
    end
    context 'no user' do
      before :each do
        when_current_user_is nil
      end
      it 'assigns the correct template to the template instance variable' do
        submit
        expect(assigns.fetch :template).to eql @template
      end
      it 'renders the show template' do
        submit
        expect(response).to render_template 'show'
      end
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'assigns the correct template to the template instance variable' do
        submit
        expect(assigns.fetch :template).to eql @template
      end
      it 'renders the show template' do
        submit
        expect(response).to render_template 'show'
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct template to the template instance variable' do
        submit
        expect(assigns.fetch :template).to eql @template
      end
      it 'renders the show template' do
        submit
        expect(response).to render_template 'show'
      end
    end
  end

  describe 'GET #new' do
    context 'staff' do
      before :each do
        @user = create :user, staff: true
        when_current_user_is @user
        @position = create :position
      end
      let :submit do
        get :new, position_id: @position.id
      end
      it 'creates an application template for that position' do
        expect(@position.application_template).to be_nil
        submit
        expect(@position.reload.application_template).not_to be_nil
      end
      it 'creates a draft for that application template for the current user' do
        submit
        draft = assigns.fetch :draft
        expect(draft.user).to eql @user
      end
      it 'assigns the created draft to a draft variable' do
        draft = create :application_draft
        expect_any_instance_of(ApplicationTemplate)
          .to receive(:create_draft).with(@user).and_return draft
        submit
        expect(assigns.fetch :draft).to eql draft
      end
      it 'redirects to the edit page for that draft' do
        submit
        draft = assigns.fetch :draft
        expect(response).to redirect_to edit_draft_path(draft)
      end
    end
  end

  describe 'GET #show' do
    before :each do
      @template = create :application_template
    end
    let :submit do
      get :show, id: @template.id
    end
    context 'no user' do
      it 'allows access' do
        when_current_user_is nil
        submit
        expect(response).not_to have_http_status :unauthorized
      end
    end
    context 'student' do
      it 'allows access' do
        when_current_user_is :student
        submit
        expect(response).not_to have_http_status :unauthorized
      end
    end
  end
end
