require 'rails_helper'

describe User do
  describe 'full_name' do
    before :each do
      @user = create :user
    end
    it 'gives first name followed by last name' do
      expect(@user.full_name).to eql "#{@user.first_name} #{@user.last_name}"
    end
  end
end
