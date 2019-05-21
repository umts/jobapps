# frozen_string_literal: true

require 'rails_helper'

describe PositionsController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[post create collection],
    %i[delete destroy member],
    %i[get edit member],
    %i[get new collection],
    %i[put update member],
    %i[get saved_applications member]
  ]
end
