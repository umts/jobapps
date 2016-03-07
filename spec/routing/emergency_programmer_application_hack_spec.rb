require 'rails_helper'

describe 'emergency programmer application hack fix' do
  context 'requesting /applications/it/programmer' do
    it 'routes to the correct template' do
      expect(get: '/applications/it/programmer')
        .to route_to controller: 'application_templates',
                     action: 'show',
                     id: 'it-programmer'
    end
  end
end
