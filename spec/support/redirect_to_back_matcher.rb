require 'rspec/expectations'

RSpec::Matchers.define :redirect_back do
  supports_block_expectations

  match do |object|
    return false unless object.is_a? Proc
    path = 'http://test.host/redirect'
    request.env['HTTP_REFERER'] = path
    object.call
    expect(response).to have_http_status :redirect
    expect(response).to redirect_to path
  end
end
