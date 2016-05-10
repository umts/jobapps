shared_examples 'an access-controlled resource' do |routes:|
  it 'denies access for student user' do
    when_current_user_is :student
    routes.each do |verb, action, params|
      send verb, action, params
      expect(response).to have_http_status :unauthorized
    end
  end
end
