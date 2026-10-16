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

  it 'denies access for a user who manages no positions' do
    when_current_user_is :anyone
    id = record ? instance_exec(&record) : 0
    routes.each do |route|
      expect { call_controller_action route, id }.to raise_error(ActionPolicy::Unauthorized)
    end
  end

  it 'denies access for a manager of a different position' do
    when_current_user_is :manager
    id = record ? instance_exec(&record) : 0
    routes.each do |route|
      expect { call_controller_action route, id }.to raise_error(ActionPolicy::Unauthorized)
    end
  end
end
