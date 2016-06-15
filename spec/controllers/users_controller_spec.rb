require 'rails_helper'

describe UsersController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:post,   :create,  :collection],
    [:delete, :destroy, :member],
    [:get,    :edit,    :member],
    [:get,    :new,     :collection],
    [:put,    :update,  :member]
  ]
  context 'user#create' do 
    it 'does not create the user' do 
      staff = create :user, :admin
      attrs = { first_name: 'Foo', last_name: 'Bar', 
                email: 'foobar@example.com', spire: '29901087'}
      binding.pry
      post :create, id: staff, user: attrs
      binding.pry
    end
  end
end
