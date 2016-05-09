require 'rails_helper'
describe Subscription do
  describe 'basic subscription creation' do
    it 'creates a valid subscription using the factory' do
      expect(create :subscription).to be_valid
    end
  end
end
