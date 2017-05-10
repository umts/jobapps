shared_examples 'an access-controlled resource' do |routes:|
  it 'denies access for student user' do
    when_current_user_is :student
    routes.each do |verb, action, route_type|
      case route_type
      when :member then send verb, action, params: { id: 0 }
      when :collection then send verb, action
      else fail ArgumentError,
                'Unknown route type: expected :member or :collection'
      end
      expect(response).to have_http_status :unauthorized
    end
  end
end
