require 'rails_helper'

describe SubscriptionsController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:post,   :create,  :collection],
    [:delete, :destroy, :member]
  ]
end
