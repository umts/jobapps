# frozen_string_literal: true

require 'rails_helper'

describe SubscriptionsController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[post create collection],
    %i[delete destroy member]
  ]
end
