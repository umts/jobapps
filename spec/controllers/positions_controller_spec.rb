require 'rails_helper'

describe PositionsController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:post,   :create,  :collection],
    [:delete, :destroy, :member],
    [:get,    :edit,    :member],
    [:get,    :new,     :collection],
    [:put,    :update,  :member]
  ]
end
