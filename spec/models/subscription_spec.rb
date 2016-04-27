require 'rails_helper'
describe Subscription do
  describe 'Basic subscription creation' do
    it 'Creates a valid subscription using the factory' do
      expect(create :subscription).to be_valid
    end
  end
end
