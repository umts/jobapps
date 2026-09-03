# frozen_string_literal: true

shared_examples 'an access-controlled resource' do |routes:|
  def call_controller_action(route)
    case route
    in [verb, action, :member]
      send verb, action, params: { id: 0 }
    in [verb, action, :collection]
      send verb, action
    end
  end

  it 'denies access for student user' do
    when_current_user_is :student
    routes.each do |route|
      expect { call_controller_action route }.to raise_error(Unauthorized)
    end
  end
end
