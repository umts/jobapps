# frozen_string_literal: true

shared_examples 'an access-controlled resource' do |routes:, record: nil|
  def call_controller_action(route, id)
    case route
    in [verb, action, :member]
      send verb, action, params: { id: }
    in [verb, action, :collection]
      send verb, action
    end
  end

  it 'denies access for student user' do
    when_current_user_is :student
    id = record ? instance_exec(&record) : 0
    routes.each do |route|
      expect { call_controller_action route, id }.to raise_error(ActionPolicy::Unauthorized)
    end
  end
end
