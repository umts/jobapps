require 'rails_helper'

describe UsersController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:post,   :create,  :collection],
    [:delete, :destroy, :member],
    [:get,    :edit,    :member],
    [:get,    :new,     :collection],
    [:put,    :update,  :member]
  ]
  describe 'POST #create' do
    context 'creating a user as staff' do
      it 'does not create the user' do
        when_current_user_is :staff
        attrs = { first_name: 'Foo', last_name: 'Bar',
                  email: 'foobar@example.com', spire: '29901087',
                  staff: true }
        post :create, user: attrs
        expect(response.status).to be 401
        expect(response.body.length).not_to be 0
      end
    end
  end
  describe 'DELETE #destroy' do 
    context 'destroying a user as staff' do
      it 'does not destroy the user' do
        when_current_user_is :staff
        user = create :user, :staff
        delete :destroy, id: user
        expect(response.body)
        expect(User.all).to include user
      end
    end
  end
  describe 'PATCH #update' do 
    context 'updating a user as staff' do 
      it 'does not update the user' do 
        when_current_user_is :staff
        user = create :user, first_name: 'Dave',
                      last_name: 'Smith', staff: true,
                      email: 'dave@example.com', spire: '123454678'
        attrs = { first_name: 'Foo', email: 'foobar@example.com' }
        patch :update, id: user, user: attrs
        user.reload
        expect(user.first_name).to eql 'Dave'
        expect(user.email).to eql 'dave@example.com'
      end
    end
  end
end
