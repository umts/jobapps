require 'rails_helper'

describe ApplicationDraftsController do
  describe 'DELETE #destroy' do
    before :each do
      @draft = create :application_draft
    end
    let :submit do
      delete :destroy, id: @draft.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationDraft)
          .not_to receive :destroy
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'destroys the draft' do
        expect_any_instance_of(ApplicationDraft)
          .to receive :destroy
        submit
      end
      it 'includes a flash message' do
        submit
        expect(flash[:message]).not_to be_empty
      end
      it 'redirects to the staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_url
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @draft = create :application_draft
    end
    let :submit do
      get :edit, id: @draft.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'adds a question to the draft, in memory only' do
        expect { submit }
          .not_to change { @draft.questions.count }
        # Factory draft has 0 questions by default
        expect(assigns.fetch(:draft).questions.size).to eql 1
      end
      it 'renders the edit template' do
        submit
        expect(response).to render_template 'edit'
      end
    end
  end
  describe 'GET #new' do
    before :each do
      @template = create :application_template
    end
    let :submit do
      get :new, application_template_id: @template.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationTemplate)
          .not_to receive :create_draft
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
