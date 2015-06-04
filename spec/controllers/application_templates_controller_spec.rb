require 'rails_helper'

describe ApplicationTemplatesController do
  describe 'GET #new' do
    before :each do
      @position = create :position
    end
    let :submit do
      get :new, position_id: @position.id
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
      let :new_template do
        ApplicationTemplate.last
      end
      it 'creates an application template for the specified position' do
        expect { submit }
          .to change { ApplicationTemplate.count }
          .by 1
        expect(new_template.position).to eql @position
      end
      it 'redirects to #edit' do
        submit
        expect(response)
          .to redirect_to edit_application_template_path(new_template)
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @template = create :application_template
    end
    let :submit do
      get :edit, id: @template.id
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      it 'renders edit' do
        when_current_user_is :staff
        submit
        expect(response).to render_template :edit
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
    context 'student' do
      it 'allows access' do
        when_current_user_is :student
        submit
        expect(response).not_to have_http_status :unauthorized
      end
    end
  end
end
